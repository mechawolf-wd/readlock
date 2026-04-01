// Course data types mirroring Readlock's CourseModel.dart
// Hierarchy: Accelerator > Segments > Packages > Swipes

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
  | FillGapQuestionBlock
  | IncorrectStatementQuestionBlock
  | EmotionalSlideBlock
  | ReflectionBlock
  | QuoteBlock
  | SkillCheckBlock

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

export interface FillGapQuestionBlock {
  'entity-type': 'fill-gap-question'
  question: string
  explanation: string
  hint?: string
  options: QuestionOption[]
  'correct-answer-indices': number[]
}

export interface IncorrectStatementQuestionBlock {
  'entity-type': 'incorrect-statement-question'
  question: string
  explanation: string
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

export interface SkillCheckBlock {
  'entity-type': 'skill-check'
  title: string
  subtitle: string
  icon: string
}

// * Entity type registry

export const ENTITY_TYPES = [
  'text',
  'single-choice-question',
  'true-false-question',
  'estimate-percentage-question',
  'fill-gap-question',
  'incorrect-statement-question',
  'emotional-slide',
  'reflection',
  'quote',
  'skill-check',
] as const

export type EntityType = typeof ENTITY_TYPES[number]

export const ENTITY_TYPE_LABELS: Record<EntityType, string> = {
  'text': 'Reading',
  'single-choice-question': 'Choice',
  'true-false-question': 'True/False',
  'estimate-percentage-question': 'Estimate',
  'fill-gap-question': 'Fill Gap',
  'incorrect-statement-question': 'Find Error',
  'emotional-slide': 'Pause',
  'reflection': 'Reflect',
  'quote': 'Quote',
  'skill-check': 'Skill Check',
}

export const ENTITY_TYPE_ICONS: Record<EntityType, string> = {
  'text': '¶',
  'single-choice-question': '○',
  'true-false-question': '⊘',
  'estimate-percentage-question': '%',
  'fill-gap-question': '⎵',
  'incorrect-statement-question': '✗',
  'emotional-slide': '♡',
  'reflection': '◎',
  'quote': '❝',
  'skill-check': '✓',
}

export const ENTITY_TYPE_COLORS: Record<EntityType, string> = {
  'text': '#94a3b8',
  'single-choice-question': '#3b82f6',
  'true-false-question': '#8b5cf6',
  'estimate-percentage-question': '#eab308',
  'fill-gap-question': '#06b6d4',
  'incorrect-statement-question': '#ef4444',
  'emotional-slide': '#f43f5e',
  'reflection': '#a855f7',
  'quote': '#14b8a6',
  'skill-check': '#10b981',
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
      'fill-gap-question',
      'incorrect-statement-question',
      'estimate-percentage-question',
    ],
  },
  {
    label: 'Interactive',
    types: ['emotional-slide', 'skill-check'],
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
