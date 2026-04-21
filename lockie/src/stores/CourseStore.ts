// Course editor store — Accelerator → Segments → Packages → Swipes

import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
import type { CourseData, Accelerator, Segment, Package, Swipe, EntityType } from '@/types/Course'
import { fetchCourseById, saveCourse } from '@/lib/FirebaseCourseService'

// * LocalStorage keys
const STORAGE_KEY = 'lockie-course-data'
const TRASH_STORAGE_KEY = 'lockie-course-trash'

// * UID generator for drag-and-drop keys
let uidCounter = 0

function generateUid(): string {
  uidCounter++
  return `swipe-${Date.now()}-${uidCounter}`
}

// Assigns internal _uid to segments, packages, swipes, and options.
// The _uid provides a stable Vue :key across mutations — segment-id / lesson-id
// are derived from position and course id, so they change on reorder / rename,
// and using them as keys would force spurious remounts.
function ensureSwipeUids(data: CourseData) {
  for (const course of data.courses) {
    course.language ??= 'EN'

    for (const segment of course.segments) {
      const segmentHasNoUid = !(segment as any)._uid

      if (segmentHasNoUid) {
        (segment as any)._uid = generateUid()
      }

      for (const pkg of segment.lessons) {
        const packageHasNoUid = !(pkg as any)._uid

        if (packageHasNoUid) {
          (pkg as any)._uid = generateUid()
        }

        for (const swipe of pkg.content) {
          const hasNoUid = !(swipe as any)._uid

          if (hasNoUid) {
            (swipe as any)._uid = generateUid()
          }

          // Ensure option uids for draggable
          const hasOptions = 'options' in swipe && Array.isArray((swipe as any).options)

          if (hasOptions) {
            for (const option of (swipe as any).options) {
              const optionHasNoUid = !option._uid

              if (optionHasNoUid) {
                option._uid = generateUid()
              }
            }
          }
        }
      }
    }
  }
}

// Derives every segment-id and lesson-id in a course from the course id + 1-based
// position. Call after any mutation that changes course-id, segment order,
// or package order, so in-memory ids always match what exportJSON would produce.
function rebuildCourseIds(course: Accelerator) {
  const courseId = course['course-id']

  for (let segmentIndex = 0; segmentIndex < course.segments.length; segmentIndex++) {
    const segment = course.segments[segmentIndex]
    const segmentNumber = segmentIndex + 1

    segment['segment-id'] = `${courseId};segment:${segmentNumber}`

    for (let lessonIndex = 0; lessonIndex < segment.lessons.length; lessonIndex++) {
      const lesson = segment.lessons[lessonIndex]
      const lessonNumber = lessonIndex + 1

      lesson['lesson-id'] = `${courseId};segment:${segmentNumber};lesson:${lessonNumber}`
    }
  }
}

export const useCourseStore = defineStore('course', () => {
  // * State

  const courseData = ref<CourseData>({ language: 'EN', courses: [] })
  const trashedCourses = ref<Accelerator[]>([])
  const activeCourseIndex = ref<number | null>(null)
  const activeSegmentIndex = ref<number>(0)
  const activePackageIndex = ref<number>(0)
  const activeSwipeUid = ref<string | null>(null)

  // * Undo state for swipe deletion (2 levels)
  const deletedSwipeStack = ref<{ swipe: Swipe; index: number }[]>([])
  const lastDeletedSwipe = computed(() => deletedSwipeStack.value.length > 0 ? deletedSwipeStack.value[0] : null)

  // * Getters

  // Resolve uid to index every time (survives reorder)
  const activeSwipeIndex = computed<number | null>(() => {
    const hasNoUid = activeSwipeUid.value === null
    const hasNoPackage = !activePackage.value

    if (hasNoUid || hasNoPackage) {
      return null
    }

    const index = activePackage.value!.content.findIndex(
      (swipe) => (swipe as any)._uid === activeSwipeUid.value
    )

    const wasNotFound = index === -1

    if (wasNotFound) {
      return null
    }

    return index
  })

  const activeCourse = computed<Accelerator | null>(() => {
    const hasNoCourseSelected = activeCourseIndex.value === null

    if (hasNoCourseSelected) {
      return null
    }

    return courseData.value.courses[activeCourseIndex.value!] ?? null
  })

  const activeSegment = computed<Segment | null>(() => {
    const hasNoCourse = !activeCourse.value

    if (hasNoCourse) {
      return null
    }

    return activeCourse.value!.segments[activeSegmentIndex.value] ?? null
  })

  const activePackage = computed<Package | null>(() => {
    const hasNoSegment = !activeSegment.value

    if (hasNoSegment) {
      return null
    }

    return activeSegment.value!.lessons[activePackageIndex.value] ?? null
  })

  const activeSwipe = computed<Swipe | null>(() => {
    const hasNoPackage = !activePackage.value
    const hasNoSwipeSelected = activeSwipeIndex.value === null

    if (hasNoPackage || hasNoSwipeSelected) {
      return null
    }

    return activePackage.value!.content[activeSwipeIndex.value!] ?? null
  })

  // * Actions

  function loadCourseData(data: CourseData) {
    ensureSwipeUids(data)
    courseData.value = data
  }

  function loadFromStorage(): boolean {
    const stored = localStorage.getItem(STORAGE_KEY)
    const hasStoredData = stored !== null

    if (hasStoredData) {
      const parsed = JSON.parse(stored!) as CourseData

      ensureSwipeUids(parsed)
      courseData.value = parsed
    }

    const storedTrash = localStorage.getItem(TRASH_STORAGE_KEY)
    const hasStoredTrash = storedTrash !== null

    if (hasStoredTrash) {
      trashedCourses.value = JSON.parse(storedTrash!)
    }

    return hasStoredData
  }

  function saveToStorage() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(courseData.value))
  }

  function saveTrashToStorage() {
    localStorage.setItem(TRASH_STORAGE_KEY, JSON.stringify(trashedCourses.value))
  }

  // * Auto-save on any course data change (debounced)

  let saveTimeout: ReturnType<typeof setTimeout> | null = null

  function debouncedSave() {
    if (saveTimeout) {
      clearTimeout(saveTimeout)
    }

    saveTimeout = setTimeout(saveToStorage, 300)
  }

  watch(courseData, debouncedSave, { deep: true })
  watch(trashedCourses, saveTrashToStorage, { deep: true })

  // Keep segment-id and lesson-id canonical whenever the course-id is edited in settings.
  watch(
    () => activeCourseIndex.value !== null ? courseData.value.courses[activeCourseIndex.value]?.['course-id'] : undefined,
    () => {
      const course = activeCourseIndex.value !== null ? courseData.value.courses[activeCourseIndex.value] : null

      if (course) {
        rebuildCourseIds(course)
      }
    },
  )

  // * Course trash actions

  function trashCourse(index: number) {
    const course = courseData.value.courses.splice(index, 1)[0]

    if (course) {
      trashedCourses.value.push(course)
    }

    const wasActiveCourse = activeCourseIndex.value === index
    const hasRemainingCourses = courseData.value.courses.length > 0

    if (wasActiveCourse) {
      if (hasRemainingCourses) {
        selectCourse(0)
      } else {
        activeCourseIndex.value = null
        activeSegmentIndex.value = 0
        activePackageIndex.value = 0
        activeSwipeUid.value = null
      }
    } else if (activeCourseIndex.value !== null && activeCourseIndex.value > index) {
      activeCourseIndex.value--
    }
  }

  function restoreCourse(trashIndex: number) {
    const course = trashedCourses.value.splice(trashIndex, 1)[0]

    if (course) {
      ensureSwipeUids({ language: 'EN', courses: [course] })
      courseData.value.courses.push(course)
    }
  }

  function permanentlyDeleteCourse(trashIndex: number) {
    trashedCourses.value.splice(trashIndex, 1)
  }

  function selectCourse(index: number) {
    activeCourseIndex.value = index
    activeSegmentIndex.value = 0
    activePackageIndex.value = 0
    activeSwipeUid.value = null
  }

  function selectSegment(index: number) {
    const isSameSegment = activeSegmentIndex.value === index

    if (isSameSegment) {
      return
    }

    activeSegmentIndex.value = index
    activePackageIndex.value = 0
    activeSwipeUid.value = null
  }

  function selectPackage(index: number) {
    const isSamePackage = activePackageIndex.value === index

    if (isSamePackage) {
      return
    }

    activePackageIndex.value = index
    activeSwipeUid.value = null
  }

  function selectSwipe(index: number) {
    const hasNoPackage = !activePackage.value

    if (hasNoPackage) {
      return
    }

    const swipe = activePackage.value!.content[index]
    const hasSwipe = swipe !== undefined

    if (hasSwipe) {
      activeSwipeUid.value = (swipe as any)._uid ?? null
    }
  }

  function selectSwipeByUid(uid: string) {
    activeSwipeUid.value = uid
  }

  function clearSwipeSelection() {
    activeSwipeUid.value = null
  }

  function addSegment() {
    const hasNoCourse = !activeCourse.value

    if (hasNoCourse) {
      return
    }

    const segmentCount = activeCourse.value!.segments.length
    const courseId = activeCourse.value!['course-id']
    const segmentNumber = segmentCount + 1
    const newSegment: Segment = {
      'segment-id': `${courseId};segment:${segmentNumber}`,
      'segment-title': `Segment ${segmentNumber}`,
      'segment-symbol': String.fromCharCode(65 + segmentCount),
      lessons: [],
    }

    ;(newSegment as any)._uid = generateUid()

    activeCourse.value!.segments.push(newSegment)
    activeSegmentIndex.value = activeCourse.value!.segments.length - 1
    activePackageIndex.value = 0

    rebuildCourseIds(activeCourse.value!)
  }

  function addPackage() {
    const hasNoSegment = !activeSegment.value

    if (hasNoSegment) {
      return
    }

    const packageCount = activeSegment.value!.lessons.length
    const courseId = activeCourse.value!['course-id']
    const segmentNumber = activeSegmentIndex.value + 1
    const lessonNumber = packageCount + 1
    const newPackage: Package = {
      'lesson-id': `${courseId};segment:${segmentNumber};lesson:${lessonNumber}`,
      title: `Package ${lessonNumber}`,
      isFree: false,
      content: [],
    }

    ;(newPackage as any)._uid = generateUid()

    activeSegment.value!.lessons.push(newPackage)
    activePackageIndex.value = activeSegment.value!.lessons.length - 1

    rebuildCourseIds(activeCourse.value!)
  }

  function removeSegment(index: number) {
    const hasNoCourse = !activeCourse.value

    if (hasNoCourse) {
      return
    }

    activeCourse.value!.segments.splice(index, 1)

    const clampedIndex = Math.min(activeSegmentIndex.value, activeCourse.value!.segments.length - 1)

    activeSegmentIndex.value = Math.max(0, clampedIndex)
    activePackageIndex.value = 0
    activeSwipeUid.value = null

    rebuildCourseIds(activeCourse.value!)
  }

  function removePackage(index: number) {
    const hasNoSegment = !activeSegment.value

    if (hasNoSegment) {
      return
    }

    activeSegment.value!.lessons.splice(index, 1)

    const clampedIndex = Math.min(activePackageIndex.value, activeSegment.value!.lessons.length - 1)

    activePackageIndex.value = Math.max(0, clampedIndex)
    activeSwipeUid.value = null

    rebuildCourseIds(activeCourse.value!)
  }

  function addSwipe(entityType: EntityType) {
    const hasNoPackage = !activePackage.value

    if (hasNoPackage) {
      return
    }

    const block = createEmptySwipe(entityType) as any

    block._uid = generateUid()

    activePackage.value!.content.push(block)
    activeSwipeUid.value = block._uid
  }

  function removeSwipe(index: number) {
    const hasNoPackage = !activePackage.value

    if (hasNoPackage) {
      return
    }

    const deletedUid = (activePackage.value!.content[index] as any)?._uid
    const deleted = activePackage.value!.content.splice(index, 1)[0]

    if (deleted) {
      deletedSwipeStack.value.unshift({ swipe: deleted, index })

      const hasMoreThanTwo = deletedSwipeStack.value.length > 2

      if (hasMoreThanTwo) {
        deletedSwipeStack.value.pop()
      }
    }

    const wasActiveSwipe = activeSwipeUid.value === deletedUid

    if (wasActiveSwipe) {
      const content = activePackage.value!.content
      const hasRemaining = content.length > 0

      if (hasRemaining) {
        const closestIndex = Math.min(index, content.length - 1)
        activeSwipeUid.value = (content[closestIndex] as any)._uid ?? null
      } else {
        activeSwipeUid.value = null
      }
    }
  }

  function undoDeleteSwipe() {
    const hasNothingToUndo = deletedSwipeStack.value.length === 0 || !activePackage.value

    if (hasNothingToUndo) {
      return
    }

    const entry = deletedSwipeStack.value.shift()!
    const clampedIndex = Math.min(entry.index, activePackage.value!.content.length)

    activePackage.value!.content.splice(clampedIndex, 0, entry.swipe)
    activeSwipeUid.value = (entry.swipe as any)._uid ?? null
  }

  function exportJSON(): string {
    // Build a deep copy with propagated IDs before serialising
    const exportData = JSON.parse(JSON.stringify(courseData.value)) as CourseData

    for (const course of exportData.courses) {
      const courseId = course['course-id']

      for (let segmentIndex = 0; segmentIndex < course.segments.length; segmentIndex++) {
        const segment = course.segments[segmentIndex]
        const segmentNumber = segmentIndex + 1

        segment['segment-id'] = `${courseId};segment:${segmentNumber}`

        for (let lessonIndex = 0; lessonIndex < segment.lessons.length; lessonIndex++) {
          const lesson = segment.lessons[lessonIndex]
          const lessonNumber = lessonIndex + 1

          lesson['lesson-id'] = `${courseId};segment:${segmentNumber};lesson:${lessonNumber}`
        }
      }
    }

    const replacer = (key: string, value: any) => {
      const isInternalUid = key === '_uid'

      if (isInternalUid) {
        return undefined
      }

      return value
    }

    return JSON.stringify(exportData, replacer, 2)
  }

  // * Active-course JSON for the in-editor viewer (per-course, not the whole dataset)
  function exportActiveCourseJSON(): string {
    const hasNoCourse = !activeCourse.value

    if (hasNoCourse) {
      return ''
    }

    const courseCopy = JSON.parse(JSON.stringify(activeCourse.value)) as Accelerator
    const courseId = courseCopy['course-id']

    for (let segmentIndex = 0; segmentIndex < courseCopy.segments.length; segmentIndex++) {
      const segment = courseCopy.segments[segmentIndex]
      const segmentNumber = segmentIndex + 1

      segment['segment-id'] = `${courseId};segment:${segmentNumber}`

      for (let lessonIndex = 0; lessonIndex < segment.lessons.length; lessonIndex++) {
        const lesson = segment.lessons[lessonIndex]
        const lessonNumber = lessonIndex + 1

        lesson['lesson-id'] = `${courseId};segment:${segmentNumber};lesson:${lessonNumber}`
      }
    }

    const replacer = (key: string, value: any) => {
      const isInternalUid = key === '_uid'

      if (isInternalUid) {
        return undefined
      }

      return value
    }

    return JSON.stringify(courseCopy, replacer, 2)
  }

  // * Reorder segments

  function moveSegmentUp() {
    const index = activeSegmentIndex.value
    const hasNoCourse = !activeCourse.value
    const isFirstItem = index <= 0

    if (hasNoCourse || isFirstItem) {
      return
    }

    const segments = activeCourse.value!.segments
    const moved = segments.splice(index, 1)[0]

    if (moved) {
      segments.splice(index - 1, 0, moved)
      activeSegmentIndex.value = index - 1
    }

    rebuildCourseIds(activeCourse.value!)
  }

  function moveSegmentDown() {
    const index = activeSegmentIndex.value
    const hasNoCourse = !activeCourse.value

    if (hasNoCourse) {
      return
    }

    const segments = activeCourse.value!.segments
    const isLastItem = index >= segments.length - 1

    if (isLastItem) {
      return
    }

    const moved = segments.splice(index, 1)[0]

    if (moved) {
      segments.splice(index + 1, 0, moved)
      activeSegmentIndex.value = index + 1
    }

    rebuildCourseIds(activeCourse.value!)
  }

  // * Reorder packages

  function movePackageUp() {
    const index = activePackageIndex.value
    const hasNoSegment = !activeSegment.value
    const isFirstItem = index <= 0

    if (hasNoSegment || isFirstItem) {
      return
    }

    const lessons = activeSegment.value!.lessons
    const moved = lessons.splice(index, 1)[0]

    if (moved) {
      lessons.splice(index - 1, 0, moved)
      activePackageIndex.value = index - 1
    }

    rebuildCourseIds(activeCourse.value!)
  }

  function movePackageDown() {
    const index = activePackageIndex.value
    const hasNoSegment = !activeSegment.value

    if (hasNoSegment) {
      return
    }

    const lessons = activeSegment.value!.lessons
    const isLastItem = index >= lessons.length - 1

    if (isLastItem) {
      return
    }

    const moved = lessons.splice(index, 1)[0]

    if (moved) {
      lessons.splice(index + 1, 0, moved)
      activePackageIndex.value = index + 1
    }

    rebuildCourseIds(activeCourse.value!)
  }

  function importJSON(json: string) {
    const parsed = JSON.parse(json) as CourseData

    loadCourseData(parsed)
  }

  function importCourse(course: Accelerator) {
    ensureSwipeUids({ language: 'EN', courses: [course] })
    rebuildCourseIds(course)

    courseData.value.courses.push(course)

    const newCourseIndex = courseData.value.courses.length - 1

    selectCourse(newCourseIndex)
  }

  function importPackageFromSwipes(title: string, swipes: Swipe[]) {
    const hasNoSegment = !activeSegment.value

    if (hasNoSegment) {
      return
    }

    // Assign UIDs to all swipes and their options
    for (const swipe of swipes) {
      (swipe as any)._uid = generateUid()

      const hasOptions = 'options' in swipe && Array.isArray((swipe as any).options)

      if (hasOptions) {
        for (const option of (swipe as any).options) {
          option._uid = generateUid()
        }
      }
    }

    const courseId = activeCourse.value!['course-id']
    const segmentNumber = activeSegmentIndex.value + 1
    const lessonNumber = activeSegment.value!.lessons.length + 1
    const newPackage: Package = {
      'lesson-id': `${courseId};segment:${segmentNumber};lesson:${lessonNumber}`,
      title,
      isFree: false,
      content: swipes,
    }

    ;(newPackage as any)._uid = generateUid()

    activeSegment.value!.lessons.push(newPackage)
    activePackageIndex.value = activeSegment.value!.lessons.length - 1
    activeSwipeUid.value = null

    rebuildCourseIds(activeCourse.value!)

    const hasSwipes = swipes.length > 0

    if (hasSwipes) {
      activeSwipeUid.value = (swipes[0] as any)._uid
    }
  }

  // * Firebase operations

  const isSavingToFirebase = ref(false)
  const firebaseSaveError = ref('')

  async function fetchCourseFromFirebase(courseId: string): Promise<Accelerator | null> {
    const course = await fetchCourseById(courseId)

    if (course) {
      ensureSwipeUids({ language: 'EN', courses: [course] })
    }

    return course
  }

  async function saveActiveCourseToFirebase(): Promise<boolean> {
    const hasNoCourse = !activeCourse.value

    if (hasNoCourse) {
      return false
    }

    isSavingToFirebase.value = true
    firebaseSaveError.value = ''

    try {
      await saveCourse(activeCourse.value!)

      isSavingToFirebase.value = false

      return true
    } catch (error) {
      console.error('[CourseStore.saveActiveCourseToFirebase]', error)

      firebaseSaveError.value = String(error)
      isSavingToFirebase.value = false

      return false
    }
  }

  return {
    courseData,
    trashedCourses,
    activeCourseIndex,
    activeSegmentIndex,
    activePackageIndex,
    activeSwipeIndex,
    activeCourse,
    activeSegment,
    activePackage,
    activeSwipe,
    isSavingToFirebase,
    firebaseSaveError,
    loadCourseData,
    loadFromStorage,
    saveToStorage,
    trashCourse,
    restoreCourse,
    permanentlyDeleteCourse,
    selectCourse,
    selectSegment,
    selectPackage,
    selectSwipe,
    addSegment,
    removeSegment,
    moveSegmentUp,
    moveSegmentDown,
    addPackage,
    removePackage,
    movePackageUp,
    movePackageDown,
    addSwipe,
    removeSwipe,
    undoDeleteSwipe,
    lastDeletedSwipe,
    selectSwipeByUid,
    clearSwipeSelection,
    exportJSON,
    exportActiveCourseJSON,
    importJSON,
    importCourse,
    importPackageFromSwipes,
    fetchCourseFromFirebase,
    saveActiveCourseToFirebase,
  }
})

// * Factory for empty swipes

function createEmptySwipe(entityType: EntityType): Swipe {
  switch (entityType) {
    case 'text': {
      return { 'entity-type': 'text', title: '', 'text-segments': [''] }
    }
    case 'question': {
      return {
        'entity-type': 'question', title: '',
        question: '', explanation: '', hint: '',
        options: [{ text: '' }, { text: '' }],
        'correct-answer-indices': [0],
      }
    }
    case 'true-false-question': {
      return {
        'entity-type': 'true-false-question', title: '',
        question: '', explanation: '', hint: '',
        options: [{ text: 'True' }, { text: 'False' }],
        'correct-answer-indices': [0],
      }
    }
    case 'estimate': {
      return {
        'entity-type': 'estimate', title: '',
        question: '', explanation: '',
        'correct-answer-indices': [50],
        'close-threshold': 10,
      }
    }
    case 'pause': {
      return { 'entity-type': 'pause', title: '', text: '', icon: 'check' }
    }
    case 'reflect': {
      return { 'entity-type': 'reflect', title: '', prompt: '', 'thinking-points': [''] }
    }
    case 'quote': {
      return { 'entity-type': 'quote', title: '', quote: '', author: '' }
    }
  }
}
