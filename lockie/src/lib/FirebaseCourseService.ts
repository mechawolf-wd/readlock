// Firestore service for reading and writing courses to /courses collection

import { doc, getDoc, setDoc } from 'firebase/firestore'
import { firestore } from '@/lib/Firebase'
import type { Accelerator } from '@/types/Course'

const COURSES_COLLECTION = 'courses'

// Firestore stores course colors as bare hex ("6A99D4"), the editor works
// with CSS-prefixed form ("#6A99D4"). These helpers keep the two in sync.
function stripHashPrefix(hex: string): string {
  if (hex.startsWith('#')) {
    return hex.slice(1)
  }

  return hex
}

function ensureHashPrefix(hex: string): string {
  if (hex.startsWith('#')) {
    return hex
  }

  return `#${hex}`
}

export async function fetchCourseById(courseId: string): Promise<Accelerator | null> {
  try {
    const courseRef = doc(firestore, COURSES_COLLECTION, courseId)
    const snapshot = await getDoc(courseRef)

    const hasNoDocument = !snapshot.exists()

    if (hasNoDocument) {
      return null
    }

    const data = snapshot.data() as Accelerator

    data['course-id'] ??= snapshot.id
    data.language ??= 'EN'

    const hasColor = typeof data.color === 'string' && data.color.length > 0

    if (hasColor) {
      data.color = ensureHashPrefix(data.color)
    }

    return data
  } catch (error) {
    console.error('[FirebaseCourseService.fetchCourseById] courseId=', courseId, error)
    throw error
  }
}

export async function saveCourse(course: Accelerator): Promise<void> {
  const courseId = course['course-id']

  course.language ??= 'EN'

  // Strip internal _uid fields before saving
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

  // Diagnostics: Firestore silently rejects payloads over 1 MiB and certain
  // field shapes; log size + structure alongside any error so the cause is
  // visible in the console.
  const serialised = JSON.stringify(cleanCourse)
  const sizeKb = (serialised.length / 1024).toFixed(1)
  const segmentCount = cleanCourse.segments?.length ?? 0
  const lessonCount = cleanCourse.segments?.reduce((sum, seg) => sum + (seg.lessons?.length ?? 0), 0) ?? 0

  try {
    const courseRef = doc(firestore, COURSES_COLLECTION, courseId)

    await setDoc(courseRef, cleanCourse)

    console.info(
      `[FirebaseCourseService.saveCourse] saved courseId=${courseId} size=${sizeKb}KB segments=${segmentCount} lessons=${lessonCount}`,
    )
  } catch (error) {
    console.error(
      `[FirebaseCourseService.saveCourse] FAILED courseId=${courseId} size=${sizeKb}KB segments=${segmentCount} lessons=${lessonCount}`,
      error,
      '\nPayload:', cleanCourse,
    )
    throw error
  }
}
