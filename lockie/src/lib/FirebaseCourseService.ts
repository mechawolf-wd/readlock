// Firestore service for reading and writing courses to /courses collection

import { doc, getDoc, setDoc } from 'firebase/firestore'
import { firestore } from '@/lib/Firebase'
import type { Accelerator } from '@/types/Course'

const COURSES_COLLECTION = 'courses'

export async function fetchCourseById(courseId: string): Promise<Accelerator | null> {
  const courseRef = doc(firestore, COURSES_COLLECTION, courseId)
  const snapshot = await getDoc(courseRef)

  const hasNoDocument = !snapshot.exists()

  if (hasNoDocument) {
    return null
  }

  const data = snapshot.data() as Accelerator

  data['course-id'] ??= snapshot.id

  return data
}

export async function saveCourse(course: Accelerator): Promise<void> {
  const courseId = course['course-id']

  // Strip internal _uid fields before saving
  const cleanCourse = JSON.parse(
    JSON.stringify(course, (key, value) => {
      const isInternalUid = key === '_uid'

      if (isInternalUid) {
        return undefined
      }

      return value
    })
  ) as Accelerator

  const courseRef = doc(firestore, COURSES_COLLECTION, courseId)

  await setDoc(courseRef, cleanCourse)
}
