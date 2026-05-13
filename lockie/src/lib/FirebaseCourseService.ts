// Firestore service for reading and writing courses to /courses collection.
//
// Lesson content lives in a subcollection (/courses/{id}/lessons/{lessonId})
// keyed by compound lesson-id (e.g. "book:X;segment:0;lesson:1").
// The main course document only carries metadata (titles, segment
// structure, isFree flags). The fetchLessonContent Cloud Function reads
// the subcollection server-side with full access-gate enforcement.

import { doc, getDoc, collection, getDocs, writeBatch } from 'firebase/firestore'
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

// Flattens segments[].lessons[] into an ordered array pairing each
// lesson's compound ID with its content array. The compound ID
// (e.g. "book:X;segment:0;lesson:1") is used as the subcollection
// document ID in Firestore.
interface LessonEntry {
  lessonId: string
  content: Swipe[]
}

function flattenLessonContent(courseId: string, segments: Segment[]): LessonEntry[] {
  const entries: LessonEntry[] = []

  for (let segmentIndex = 0; segmentIndex < segments.length; segmentIndex++) {
    const segment = segments[segmentIndex]!
    const segmentLessons = segment.lessons ?? []

    for (let lessonIndex = 0; lessonIndex < segmentLessons.length; lessonIndex++) {
      const lesson = segmentLessons[lessonIndex]!
      const lessonContent = lesson.content ?? []
      const lessonId = `${courseId};segment:${segmentIndex};lesson:${lessonIndex}`

      entries.push({ lessonId, content: lessonContent })
    }
  }

  return entries
}

// Returns a deep copy of the course with content arrays removed from
// every lesson. The content is saved separately to the subcollection.
function stripContentFromCourse(course: Accelerator): Accelerator {
  const stripped = structuredClone(course)

  const strippedSegments = stripped.segments ?? []

  for (const segment of strippedSegments) {
    const segmentLessons = segment.lessons ?? []

    for (const lesson of segmentLessons) {
      delete (lesson as any).content
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
    // into the course structure. Documents are keyed by compound
    // lesson-id (e.g. "book:X;segment:0;lesson:1"), matched against
    // each lesson's lesson-id field in the metadata.
    const lessonsRef = collection(firestore, COURSES_COLLECTION, courseId, LESSONS_SUBCOLLECTION)
    const lessonsSnapshot = await getDocs(lessonsRef)

    const contentByLessonId: Map<string, Swipe[]> = new Map()

    for (const lessonDocument of lessonsSnapshot.docs) {
      const lessonData = lessonDocument.data() as { content: Swipe[] }
      const contentArray = lessonData.content ?? []

      contentByLessonId.set(lessonDocument.id, contentArray)
    }

    // Walk the segments in order and assign content by lesson-id.
    const dataSegments = data.segments ?? []

    for (let segmentIndex = 0; segmentIndex < dataSegments.length; segmentIndex++) {
      const segment = dataSegments[segmentIndex]!
      const segmentLessons = segment.lessons ?? []

      for (let lessonIndex = 0; lessonIndex < segmentLessons.length; lessonIndex++) {
        const lesson = segmentLessons[lessonIndex]!
        const lessonId = `${courseId};segment:${segmentIndex};lesson:${lessonIndex}`
        const restoredContent = contentByLessonId.get(lessonId) ?? []

        lesson.content = restoredContent
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
  const lessonEntries = flattenLessonContent(courseId, cleanCourse.segments ?? [])
  const metadataOnly = stripContentFromCourse(cleanCourse)

  const rawSegmentCount = metadataOnly.segments?.length
  const segmentCount = rawSegmentCount ?? 0
  const lessonCount = lessonEntries.length
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
    // Document ID = compound lesson-id (e.g. "book:X;segment:0;lesson:1").
    for (const entry of lessonEntries) {
      const lessonRef = doc(
        firestore,
        COURSES_COLLECTION,
        courseId,
        LESSONS_SUBCOLLECTION,
        entry.lessonId,
      )

      batch.set(lessonRef, { content: entry.content })
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
