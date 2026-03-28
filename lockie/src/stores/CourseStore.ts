// Course editor store — Accelerator → Segments → Packages → Swipes

import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
import type { CourseData, Accelerator, Segment, Package, Swipe, EntityType } from '@/types/Course'

// * LocalStorage key
const STORAGE_KEY = 'lockie-course-data'

// * UID generator for drag-and-drop keys
let uidCounter = 0

function generateUid(): string {
  uidCounter++
  return `swipe-${Date.now()}-${uidCounter}`
}

function ensureSwipeUids(data: CourseData) {
  for (const course of data.courses) {
    for (const segment of course.segments) {
      for (const pkg of segment.lessons) {
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

export const useCourseStore = defineStore('course', () => {
  // * State

  const courseData = ref<CourseData>({ language: 'EN', courses: [] })
  const activeCourseIndex = ref<number | null>(null)
  const activeSegmentIndex = ref<number>(0)
  const activePackageIndex = ref<number>(0)
  const activeSwipeUid = ref<string | null>(null)

  // * Undo state for swipe deletion
  const lastDeletedSwipe = ref<{ swipe: Swipe; index: number } | null>(null)

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
      return true
    }

    return false
  }

  function saveToStorage() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(courseData.value))
  }

  // * Auto-save on any course data change
  watch(courseData, saveToStorage, { deep: true })

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
    const newSegment = {
      'segment-id': `segment-${segmentCount + 1}`,
      'segment-title': `Segment ${segmentCount + 1}`,
      'segment-description': '',
      'segment-symbol': String.fromCharCode(65 + segmentCount),
      lessons: [],
    }

    activeCourse.value!.segments.push(newSegment)
    activeSegmentIndex.value = activeCourse.value!.segments.length - 1
    activePackageIndex.value = 0
  }

  function addPackage() {
    const hasNoSegment = !activeSegment.value

    if (hasNoSegment) {
      return
    }

    const packageCount = activeSegment.value!.lessons.length
    const newPackage = {
      'lesson-id': `package-${packageCount + 1}`,
      title: `Package ${packageCount + 1}`,
      isFree: false,
      content: [],
    }

    activeSegment.value!.lessons.push(newPackage)
    activePackageIndex.value = activeSegment.value!.lessons.length - 1
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
      lastDeletedSwipe.value = { swipe: deleted, index }
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
    const hasNothingToUndo = !lastDeletedSwipe.value || !activePackage.value

    if (hasNothingToUndo) {
      return
    }

    const { swipe, index } = lastDeletedSwipe.value!
    const clampedIndex = Math.min(index, activePackage.value!.content.length)

    activePackage.value!.content.splice(clampedIndex, 0, swipe)
    activeSwipeUid.value = (swipe as any)._uid ?? null
    lastDeletedSwipe.value = null
  }

  function exportJSON(): string {
    return JSON.stringify(courseData.value, null, 2)
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
  }

  function importJSON(json: string) {
    const parsed = JSON.parse(json) as CourseData

    loadCourseData(parsed)
  }

  return {
    courseData,
    activeCourseIndex,
    activeSegmentIndex,
    activePackageIndex,
    activeSwipeIndex,
    activeCourse,
    activeSegment,
    activePackage,
    activeSwipe,
    loadCourseData,
    loadFromStorage,
    saveToStorage,
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
    importJSON,
  }
})

// * Factory for empty swipes

function createEmptySwipe(entityType: EntityType): Swipe {
  switch (entityType) {
    case 'text': {
      return { 'entity-type': 'text', 'text-segments': [''] }
    }
    case 'single-choice-question': {
      return {
        'entity-type': 'single-choice-question',
        question: '', explanation: '', hint: '',
        options: [{ text: '' }, { text: '' }],
        'correct-answer-indices': [0],
      }
    }
    case 'true-false-question': {
      return {
        'entity-type': 'true-false-question',
        question: '', explanation: '', hint: '',
        options: [{ text: 'True' }, { text: 'False' }],
        'correct-answer-indices': [0],
      }
    }
    case 'estimate-percentage-question': {
      return {
        'entity-type': 'estimate-percentage-question',
        question: '', explanation: '',
        options: [],
        'correct-answer-indices': [50],
      }
    }
    case 'fill-gap-question': {
      return {
        'entity-type': 'fill-gap-question',
        question: '', explanation: '', hint: '',
        options: [{ text: '' }],
        'correct-answer-indices': [0],
      }
    }
    case 'incorrect-statement-question': {
      return {
        'entity-type': 'incorrect-statement-question',
        question: '', explanation: '',
        options: [{ text: '' }, { text: '' }, { text: '' }],
        'correct-answer-indices': [0],
      }
    }
    case 'reflection-question': {
      return {
        'entity-type': 'reflection-question',
        question: '', explanation: '',
        options: [{ text: '' }],
        'correct-answer-indices': [0],
      }
    }
    case 'emotional-slide': {
      return { 'entity-type': 'emotional-slide', text: '', icon: 'check' }
    }
    case 'reflection': {
      return { 'entity-type': 'reflection', prompt: '', 'thinking-points': [''] }
    }
    case 'quote': {
      return { 'entity-type': 'quote', quote: '', author: '' }
    }
    case 'skill-check': {
      return { 'entity-type': 'skill-check' }
    }
  }
}
