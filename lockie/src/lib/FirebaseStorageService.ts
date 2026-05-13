// Firebase Storage service for course cover images.
// Files are stored at /course-covers/{courseId}.{ext}, one cover per course,
// reuploads overwrite the previous object.

import { ref as storageRef, uploadBytes, getDownloadURL } from 'firebase/storage'
import { storage } from '@/lib/Firebase'

const COURSE_COVERS_PATH = 'course-covers'

export async function uploadCourseCoverImage(courseId: string, file: File): Promise<string> {
  const extension = extractExtension(file)
  const objectPath = `${COURSE_COVERS_PATH}/${courseId}.${extension}`

  try {
    const objectRef = storageRef(storage, objectPath)

    await uploadBytes(objectRef, file, { contentType: file.type })

    const downloadUrl = await getDownloadURL(objectRef)

    console.info(
      `[FirebaseStorageService.uploadCourseCoverImage] uploaded courseId=${courseId} path=${objectPath} size=${(file.size / 1024).toFixed(1)}KB`,
    )

    return downloadUrl
  } catch (error) {
    console.error(
      `[FirebaseStorageService.uploadCourseCoverImage] FAILED courseId=${courseId} path=${objectPath}`,
      error,
    )
    throw error
  }
}

function extractExtension(file: File): string {
  const rawExtension = file.name.split('.').pop()?.toLowerCase()
  const fromName = rawExtension ?? ''
  const hasExtension = fromName !== '' && fromName !== file.name

  if (hasExtension) {
    return fromName
  }

  // Fallback to MIME subtype when filename has no extension (e.g., pasted blobs).
  const rawMimeSubtype = file.type.split('/').pop()?.toLowerCase()
  const fromMime = rawMimeSubtype ?? ''
  const hasMimeSubtype = fromMime !== ''

  if (hasMimeSubtype) {
    return fromMime
  }

  return 'jpg'
}
