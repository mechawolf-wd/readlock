// Firestore service for reading and writing courses to /courses collection.
//
// Lesson content lives in a subcollection (/courses/{id}/lessons/{index})
// so the main course document only carries metadata (titles, segment
// structure, isFree flags, etc.). This keeps content out of direct
// client reads on the Readlock web app, where Firestore responses are
// visible in DevTools. The fetchLessonContent Cloud Function reads the
// subcollection server-side with full access-gate enforcement.

import { doc, getDoc, collection, getDocs, writeBatch, query, orderBy } from 'firebase/firestore'
import { firestore } from '@/lib/Firebase'
import type { Accelerator, Segment, Package, Swipe } from '@/types/Course'

const COURSES_COLLECTION = 'courses'
const LESSONS_SUBCOLLECTION = 'lessons'

// Firestore stores course colors as bare hex ("6A99D4"), the editor works
// with CSS-prefixed form ("#6A99D4"). These helpers keep the two in sync.
function stripHashPrefix(hex: string): string {
  const hasHash = hex.startsWith('#')

  if (hasHash) {
    return hex.slice(1)
  }

  return hex
}

function ensureHashPrefix(hex: string): string {
  const hasHash = hex.startsWith('#')

  if (hasHash) {
    return hex
  }

  return `#${hex}`
}

// Flattens segments[].lessons[] into a single ordered array of content
// arrays, one per lesson. The flat index matches the Flutter client's
// currentLessonIndex and the Cloud Function's lessonIndex parameter.
function flattenLessonContent(segments: Segment[]): Swipe[][] {
  const allContent: Swipe[][] = []

  for (const segment of segments) {
    const segmentLessons = segment.lessons ?? []

    for (const lesson of segmentLessons) {
      const lessonContent = lesson.content ?? []

      allContent.push(lessonContent)
    }
  }

  return allContent
}

// Returns a deep copy of the course with content arrays removed from
// every lesson. The content is saved separately to the subcollection.
function stripContentFromCourse(course: Accelerator): Accelerator {
  const stripped = structuredClone(course)

  const strippedSegments = stripped.segments ?? []

  for (const segment of strippedSegments) {
    const segmentLessons = segment.lessons ?? []

    for (const lesson of segmentLessons) {
      lesson.content = []
    }
  }

  return stripped
}

export async function courseExistsInFirebase(courseId: string): Promise<boolean> {
  const courseRef = doc(firestore, COURSES_COLLECTION, courseId)
  const snapshot = await getDoc(courseRef)

  return snapshot.exists()
}

// Fetches a course and reconstructs its lesson content from the
// /courses/{id}/lessons/{index} subcollection. Lockie needs the full
// course (including content) for editing.
export async function fetchCourseById(courseId: string): Promise<Accelerator | null> {
  try {
    const courseRef = doc(firestore, COURSES_COLLECTION, courseId)
    const snapshot = await getDoc(courseRef)

    const hasNoDocument = !snapshot.exists()

    if (hasNoDocument) {
      return null
    }

    const data = snapshot.data() as Accelerator

    const hasCourseId = data['course-id'] !== undefined && data['course-id'] !== null
    const hasLanguage = data.language !== undefined && data.language !== null

    if (!hasCourseId) {
      data['course-id'] = snapshot.id
    }

    if (!hasLanguage) {
      data.language = 'EN'
    }

    const hasColor = typeof data.color === 'string' && data.color.length > 0

    if (hasColor) {
      data.color = ensureHashPrefix(data.color)
    }

    // Read lesson content from the subcollection and stitch it back
    // into the course structure. Documents are named by flat index
    // ("0", "1", "2", ...) and ordered numerically so they map 1:1
    // to the flattened segments[].lessons[] array.
    const lessonsRef = collection(firestore, COURSES_COLLECTION, courseId, LESSONS_SUBCOLLECTION)
    const lessonsQuery = query(lessonsRef, orderBy('__name__'))
    const lessonsSnapshot = await getDocs(lessonsQuery)

    const contentByIndex: Map<number, Swipe[]> = new Map()

    for (const lessonDocument of lessonsSnapshot.docs) {
      const lessonIndex = Number(lessonDocument.id)
      const lessonData = lessonDocument.data() as { content: Swipe[] }

      const contentArray = lessonData.content ?? []

      contentByIndex.set(lessonIndex, contentArray)
    }

    // Walk the segments in order and assign content back by flat index.
    let flatIndex = 0

    const dataSegments = data.segments ?? []

    for (const segment of dataSegments) {
      const segmentLessons = segment.lessons ?? []

      for (const lesson of segmentLessons) {
        const restoredContent = contentByIndex.get(flatIndex) ?? []

        lesson.content = restoredContent
        flatIndex++
      }
    }

    return data
  } catch (error) {
    console.error('[FirebaseCourseService.fetchCourseById] courseId=', courseId, error)
    throw error
  }
}

export async function saveCourse(course: Accelerator): Promise<void> {
  const courseId = course['course-id']

  const hasLanguage = course.language !== undefined && course.language !== null

  if (!hasLanguage) {
    course.language = 'EN'
  }

  // Strip internal _uid fields before saving.
  const cleanCourse = JSON.parse(
    JSON.stringify(course, (key: string, value: unknown) => {
      const isInternalUid = key === '_uid'

      if (isInternalUid) {
        return undefined
      }

      return value
    })
  ) as Accelerator

  // Normalise color to Firestore's stored form (no '#').
  const hasColor = typeof cleanCourse.color === 'string' && cleanCourse.color.length > 0

  if (hasColor) {
    cleanCourse.color = stripHashPrefix(cleanCourse.color)
  }

  // Lifetime purchase counter. Brand-new courses start at 0; existing
  // courses keep whatever the Flutter app has incremented to so far. We
  // re-read the existing document (cheap, single get) instead of using
  // setDoc(merge:true) because the rest of the payload is a full overwrite
  // and merge would silently leave orphaned fields behind on edits.
  const existingDocument = await getDoc(doc(firestore, COURSES_COLLECTION, courseId))
  const hasExistingDocument = existingDocument.exists()
  const existingData = hasExistingDocument ? existingDocument.data() as Accelerator : null
  const previousTimesPurchased = existingData?.timesPurchased ?? 0

  cleanCourse.timesPurchased = previousTimesPurchased

  // Extract lesson content before stripping it from the main document.
  const allLessonContent = flattenLessonContent(cleanCourse)
  const metadataOnly = stripContentFromCourse(cleanCourse)

  const rawSegmentCount = metadataOnly.segments?.length
  const segmentCount = rawSegmentCount ?? 0
  const lessonCount = allLessonContent.length
  const metadataSizeKb = (JSON.stringify(metadataOnly).length / 1024).toFixed(1)

  try {
    // Use a batched write so the main document and all lesson subcollection
    // documents land atomically. Firestore batches support up to 500 ops;
    // even a large course (30 lessons + 1 main doc) fits comfortably.
    const batch = writeBatch(firestore)

    // Write the main course document (metadata only, no content)
    const courseRef = doc(firestore, COURSES_COLLECTION, courseId)
    batch.set(courseRef, metadataOnly)

    // Write each lesson's content to the subcollection.
    // Document ID = flat lesson index ("0", "1", "2", ...).
    for (let lessonIndex = 0; lessonIndex < allLessonContent.length; lessonIndex++) {
      const lessonRef = doc(
        firestore,
        COURSES_COLLECTION,
        courseId,
        LESSONS_SUBCOLLECTION,
        String(lessonIndex),
      )

      batch.set(lessonRef, { content: allLessonContent[lessonIndex] })
    }

    await batch.commit()

    console.info(
      `[FirebaseCourseService.saveCourse] saved courseId=${courseId} metadata=${metadataSizeKb}KB segments=${segmentCount} lessons=${lessonCount}`,
    )
  } catch (error) {
    console.error(
      `[FirebaseCourseService.saveCourse] FAILED courseId=${courseId} metadata=${metadataSizeKb}KB segments=${segmentCount} lessons=${lessonCount}`,
      error,
      '\nPayload:', metadataOnly,
    )
    throw error
  }
}
