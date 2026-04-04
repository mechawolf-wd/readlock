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
  title: string
  author: string
  description: string
  'cover-image-path': string
  color: string
  'relevant-for': string[]
  genres: string[]
  segments: Segment[]
}

export interface Segment {
  'segment-id': string
  'segment-title': string
  'segment-description': string
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
  | SingleChoiceQuestionBlock
  | TrueFalseQuestionBlock
  | EstimatePercentageQuestionBlock
  | EmotionalSlideBlock
  | ReflectionBlock
  | QuoteBlock

export interface TextBlock {
  'entity-type': 'text'
  'text-segments': string[]
}

export interface QuestionOption {
  text: string
  'consequence-message'?: string
  hint?: string
}

export interface SingleChoiceQuestionBlock {
  'entity-type': 'single-choice-question'
  question: string
  explanation: string
  hint?: string
  options: QuestionOption[]
  'correct-answer-indices': number[]
}

export interface TrueFalseQuestionBlock {
  'entity-type': 'true-false-question'
  question: string
  explanation: string
  hint?: string
  options: QuestionOption[]
  'correct-answer-indices': number[]
}

export interface EstimatePercentageQuestionBlock {
  'entity-type': 'estimate-percentage-question'
  question: string
  explanation: string
  hint?: string
  options: QuestionOption[]
  'correct-answer-indices': number[]
}

export interface EmotionalSlideBlock {
  'entity-type': 'emotional-slide'
  text: string
  icon?: string
}

export interface ReflectionBlock {
  'entity-type': 'reflection'
  prompt: string
  'thinking-points': string[]
}

export interface QuoteBlock {
  'entity-type': 'quote'
  quote: string
  author: string
}

// * Entity type registry

export const ENTITY_TYPES = [
  'text',
  'single-choice-question',
  'true-false-question',
  'estimate-percentage-question',
  'emotional-slide',
  'reflection',
  'quote',
] as const

export type EntityType = typeof ENTITY_TYPES[number]

export const ENTITY_TYPE_LABELS: Record<EntityType, string> = {
  'text': 'Page',
  'single-choice-question': 'Question',
  'true-false-question': 'True/False',
  'estimate-percentage-question': 'Estimate',
  'emotional-slide': 'Pause',
  'reflection': 'Reflect',
  'quote': 'Quote',
}

export const ENTITY_TYPE_ICONS: Record<EntityType, Component> = {
  'text': BookOpen,
  'single-choice-question': CircleHelp,
  'true-false-question': ToggleLeft,
  'estimate-percentage-question': Percent,
  'emotional-slide': Heart,
  'reflection': Brain,
  'quote': MessageSquareQuote,
}

export const ENTITY_TYPE_COLORS: Record<EntityType, string> = {
  'text': 'var(--entity-text)',
  'single-choice-question': 'var(--entity-question)',
  'true-false-question': 'var(--entity-question)',
  'estimate-percentage-question': 'var(--entity-question)',
  'emotional-slide': 'var(--entity-emotional)',
  'reflection': 'var(--entity-text)',
  'quote': 'var(--entity-text)',
}

export interface EntityTypeGroup {
  label: string
  types: EntityType[]
}

export const ENTITY_TYPE_GROUPS: EntityTypeGroup[] = [
  {
    label: 'Reading',
    types: ['text', 'quote', 'reflection'],
  },
  {
    label: 'Questions',
    types: [
      'single-choice-question',
      'true-false-question',
      'estimate-percentage-question',
    ],
  },
  {
    label: 'Interactive',
    types: ['emotional-slide'],
  },
]

export const QUICK_ADD_TYPES: EntityType[] = [
  'text',
  'single-choice-question',
  'true-false-question',
]

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
