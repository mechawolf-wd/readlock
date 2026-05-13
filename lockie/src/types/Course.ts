// Course data types mirroring Readlock's CourseModel.dart
// Hierarchy: Accelerator > Segments > Packages > Swipes

import { BookOpen, CircleHelp, ToggleLeft, Percent, Heart, Brain, MessageSquareQuote } from 'lucide-vue-next'
import type { Component } from 'vue'

export interface CourseData {
  language: string
  courses: Accelerator[]
}

export interface Accelerator {
  'course-id': string
  language: string
  title: string
  author: string
  description: string
  color: string
  'relevant-for': string[]
  genres: string[]
  'preloaded-assets'?: string[]
  // Lifetime purchase counter. Seeded to 0 on a brand-new save and bumped
  // by the Flutter app on every successful unlock. Lockie never edits this
  // value directly; saveCourse() only preserves whatever is already in
  // Firestore (or 0 for first-time saves) so editing a course doesn't
  // reset the count.
  timesPurchased?: number
  segments: Segment[]
}

export interface Segment {
  'segment-id': string
  'segment-title': string
  'segment-symbol': string
  lessons: Package[]
}

export interface Package {
  'lesson-id': string
  title: string
  isFree: boolean
  content: Swipe[]
}

export type Swipe =
  | TextBlock
  | QuestionBlock
  | TrueFalseQuestionBlock
  | EstimateBlock
  | PauseBlock
  | ReflectBlock
  | QuoteBlock

export interface TextBlock {
  'entity-type': 'text'
  title?: string
  'text-segments': string[]
}

export interface QuestionOption {
  text: string
  'consequence-message'?: string
  hint?: string
}

export interface QuestionBlock {
  'entity-type': 'question'
  title?: string
  question: string
  explanation: string
  hint?: string
  options: QuestionOption[]
  'correct-answer-indices': number[]
}

export interface TrueFalseQuestionBlock {
  'entity-type': 'true-false-question'
  title?: string
  question: string
  explanation: string
  hint?: string
  options: QuestionOption[]
  'correct-answer-indices': number[]
}

export interface EstimateBlock {
  'entity-type': 'estimate'
  title?: string
  question: string
  explanation: string
  hint?: string
  'correct-answer-indices': number[]
  'close-threshold'?: number
}

export interface PauseBlock {
  'entity-type': 'pause'
  title?: string
  text: string
  icon?: string
}

export interface ReflectBlock {
  'entity-type': 'reflect'
  title?: string
  prompt: string
  'thinking-points': string[]
}

export interface QuoteBlock {
  'entity-type': 'quote'
  title?: string
  quote: string
  author: string
}

// * Entity type registry

export const ENTITY_TYPES = [
  'text',
  'question',
  'true-false-question',
  'estimate',
  'pause',
  'reflect',
  'quote',
] as const

export type EntityType = typeof ENTITY_TYPES[number]

export const ENTITY_TYPE_LABELS: Record<EntityType, string> = {
  'text': 'Page',
  'question': 'Question',
  'true-false-question': 'True/False',
  'estimate': 'Estimate',
  'pause': 'Pause',
  'reflect': 'Reflect',
  'quote': 'Quote',
}

export const ENTITY_TYPE_ICONS: Record<EntityType, Component> = {
  'text': BookOpen,
  'question': CircleHelp,
  'true-false-question': ToggleLeft,
  'estimate': Percent,
  'pause': Heart,
  'reflect': Brain,
  'quote': MessageSquareQuote,
}

export const ENTITY_TYPE_COLORS: Record<EntityType, string> = {
  'text': 'var(--entity-text)',
  'question': 'var(--entity-question)',
  'true-false-question': 'var(--entity-question)',
  'estimate': 'var(--entity-question)',
  'pause': 'var(--entity-emotional)',
  'reflect': 'var(--entity-text)',
  'quote': 'var(--entity-text)',
}

export interface EntityTypeGroup {
  label: string
  types: EntityType[]
}

export const ENTITY_TYPE_GROUPS: EntityTypeGroup[] = [
  {
    label: 'Reading',
    types: ['text', 'quote', 'reflect'],
  },
  {
    label: 'Questions',
    types: [
      'question',
      'true-false-question',
      'estimate',
    ],
  },
  {
    label: 'Interactive',
    types: ['pause'],
  },
]

export const QUICK_ADD_TYPES: EntityType[] = [
  'text',
  'question',
  'true-false-question',
]

// * Course theme colors, the closed palette. A course color MUST be one of these.
// Writers are encouraged to pick whichever swatch best matches the original book cover.

export const COURSE_COLORS: string[] = [
  '#9E7071',
  '#D0CBD6',
  '#C78871',
  '#FAF0A2',
  '#8461BD',
  '#78A3ED',
  '#72ACAD',
  '#C85159',
  '#6D7487',
  '#CAC7EE',
  '#6A99D4',
  '#FFC1E2',
]

export const DEFAULT_COURSE_COLOR: string = COURSE_COLORS[0]

// Canonical closed list mirrored in copywriting/ReadlockInstructor.xml and
// readlock/lib/constants/RLCourseGenres.dart. Authors pick 3 to 5 from
// this set when filling a course's `genres:` field, no invented tags.
export const PREMADE_GENRES: string[] = [
  'design',
  'psychology',
  'business',
  'technology',
  'self-help',
  'science',
  'philosophy',
  'history',
  'economics',
  'leadership',
  'creativity',
  'productivity',
  'communication',
  'user-experience',
  'product-development',
]
