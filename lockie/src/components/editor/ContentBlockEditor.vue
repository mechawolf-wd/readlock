<script setup lang="ts">
// Editor form for a single content block
// Renders the correct fields based on entity-type

import { ref, computed, watch, onUnmounted, onMounted } from 'vue'
import type { Swipe } from '@/types/Course'
import { ENTITY_TYPE_LABELS, ENTITY_TYPE_COLORS, type EntityType } from '@/types/Course'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { Checkbox } from '@/components/ui/checkbox'
import { ScrollArea } from '@/components/ui/scroll-area'
import Sortable from 'sortablejs'
import { Minus, Plus, PlusCircle, BookOpen, Sparkles, ImageIcon, GripVertical, ChevronUp, ChevronDown, Type, Undo2 } from 'lucide-vue-next'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover'
import RichTextSegment from '@/components/editor/RichTextSegment.vue'

const props = defineProps<{ block: Swipe }>()

const entityLabel = ENTITY_TYPE_LABELS[props.block['entity-type'] as EntityType] ?? props.block['entity-type']
const entityColor = ENTITY_TYPE_COLORS[props.block['entity-type'] as EntityType] ?? 'var(--muted-foreground)'

// * Stable keys for text segments (strings have no UID)

let segmentKeyCounter = 0
const segmentKeys = ref<number[]>([])

function initSegmentKeys() {
  const hasTextSegments = 'text-segments' in props.block

  if (hasTextSegments) {
    segmentKeys.value = props.block['text-segments'].map(() => segmentKeyCounter++)
  }
}

initSegmentKeys()

function getSegmentKey(segmentIndex: number): number {
  return segmentKeys.value[segmentIndex] ?? segmentIndex
}

// * Text segment actions

function addTextSegment() {
  const hasTextSegments = 'text-segments' in props.block

  if (hasTextSegments) {
    props.block['text-segments'].push('')
    segmentKeys.value.push(segmentKeyCounter++)
  }
}

function insertTextSegmentAfter(segmentIndex: number) {
  const hasTextSegments = 'text-segments' in props.block

  if (hasTextSegments) {
    props.block['text-segments'].splice(segmentIndex + 1, 0, '')
    segmentKeys.value.splice(segmentIndex + 1, 0, segmentKeyCounter++)
  }
}

const deletedSegmentStack = ref<{ text: string; index: number; key: number }[]>([])

function removeTextSegment(segmentIndex: number) {
  const hasTextSegments = 'text-segments' in props.block
  const hasMultipleSegments = hasTextSegments && props.block['text-segments'].length > 1

  if (hasMultipleSegments) {
    const removedText = props.block['text-segments'].splice(segmentIndex, 1)[0]
    const removedKey = segmentKeys.value.splice(segmentIndex, 1)[0]

    deletedSegmentStack.value.unshift({ text: removedText, index: segmentIndex, key: removedKey })

    const hasMoreThanTwo = deletedSegmentStack.value.length > 2

    if (hasMoreThanTwo) {
      deletedSegmentStack.value.pop()
    }
  }
}

function undoDeleteSegment() {
  const hasNothingToUndo = deletedSegmentStack.value.length === 0

  if (hasNothingToUndo) {
    return
  }

  const hasTextSegments = 'text-segments' in props.block

  if (hasTextSegments) {
    const entry = deletedSegmentStack.value.shift()!
    const clampedIndex = Math.min(entry.index, props.block['text-segments'].length)

    props.block['text-segments'].splice(clampedIndex, 0, entry.text)
    segmentKeys.value.splice(clampedIndex, 0, entry.key)
  }
}

// * Raw text editor

const showRawTextEditor = ref(false)
const rawTextInput = ref('')

function enterRawTextMode() {
  const hasTextSegments = 'text-segments' in props.block

  if (hasTextSegments) {
    rawTextInput.value = props.block['text-segments'].join('\n')
  }

  showRawTextEditor.value = true
}

function cleanText(text: string): string {
  return text
    .replace(/\r\n/g, '\n')
    .replace(/\r/g, '\n')
    .replace(/\t/g, ' ')
    .replace(/\u00A0/g, ' ')
    .replace(/[\u200B\u200C\u200D\uFEFF]/g, '')
    .replace(/ {2,}/g, ' ')
}

function handleConvertRawText() {
  const hasTextSegments = 'text-segments' in props.block
  const hasContent = rawTextInput.value.trim() !== ''

  if (!hasTextSegments || !hasContent) {
    return
  }

  const cleaned = cleanText(rawTextInput.value)
  const lines = cleaned.split('\n').map(line => line.trim()).filter(line => line !== '')

  props.block['text-segments'] = lines
  segmentKeys.value = lines.map(() => segmentKeyCounter++)
  deletedSegmentStack.value = []
  rawTextInput.value = ''
  showRawTextEditor.value = false
}

// * Option actions

function addOption() {
  const hasOptions = 'options' in props.block

  if (hasOptions) {
    const newOption = { text: '' } as any

    newOption._uid = `opt-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`
    props.block.options.push(newOption)
  }
}

function insertOptionAfter(optionIndex: number) {
  const hasOptions = 'options' in props.block

  if (hasOptions) {
    const newOption = { text: '' } as any

    newOption._uid = `opt-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`
    props.block.options.splice(optionIndex + 1, 0, newOption)
  }
}

function removeOption(optionIndex: number) {
  const hasOptions = 'options' in props.block
  const hasMultipleOptions = hasOptions && props.block.options.length > 1

  if (hasMultipleOptions) {
    props.block.options.splice(optionIndex, 1)
  }
}

function moveOptionUp(optionIndex: number) {
  const isFirst = optionIndex === 0

  if (isFirst) {
    return
  }

  const options = props.block.options
  const moved = options.splice(optionIndex, 1)[0]
  options.splice(optionIndex - 1, 0, moved)
}

function moveOptionDown(optionIndex: number) {
  const options = props.block.options
  const isLast = optionIndex >= options.length - 1

  if (isLast) {
    return
  }

  const moved = options.splice(optionIndex, 1)[0]
  options.splice(optionIndex + 1, 0, moved)
}

// * Thinking point actions

function addThinkingPoint() {
  const hasThinkingPoints = 'thinking-points' in props.block

  if (hasThinkingPoints) {
    props.block['thinking-points'].push('')
  }
}

function removeThinkingPoint(pointIndex: number) {
  const hasThinkingPoints = 'thinking-points' in props.block
  const hasMultiplePoints = hasThinkingPoints && props.block['thinking-points'].length > 1

  if (hasMultiplePoints) {
    props.block['thinking-points'].splice(pointIndex, 1)
  }
}

// * Correct answer toggle

function isCorrectAnswer(optionIndex: number): boolean {
  const hasIndices = 'correct-answer-indices' in props.block

  if (!hasIndices) {
    return false
  }

  return (props.block as any)['correct-answer-indices'].includes(optionIndex)
}

function toggleCorrectAnswer(optionIndex: number) {
  const hasIndices = 'correct-answer-indices' in props.block

  if (!hasIndices) {
    return
  }

  const indices: number[] = (props.block as any)['correct-answer-indices']
  const currentPosition = indices.indexOf(optionIndex)
  const isCurrentlyCorrect = currentPosition !== -1

  if (isCurrentlyCorrect) {
    indices.splice(currentPosition, 1)
  } else {
    indices.push(optionIndex)
  }
}

// * AI prompt state

const aiSlidePrompt = ref('')
const showAIMenu = ref(false)
const showGuidelinesDialog = ref(false)

// * AI action groups per entity type category

const TEXT_AI_GROUPS = [
  {
    label: 'Writing',
    actions: [
      { label: 'Fix grammar', prompt: 'Fix grammar and spelling errors in this slide' },
      { label: 'Make concise', prompt: 'Make the text more concise without losing meaning' },
      { label: 'Pop-scientific', prompt: 'Rewrite in an engaging popular science tone — vivid, surprising, accessible' },
      { label: 'Simplify', prompt: 'Simplify the language for easier reading' },
    ],
  },
  {
    label: 'Structure',
    actions: [
      { label: 'Split segments', prompt: 'Split the text into shorter, punchier segments' },
      { label: 'Add emphasis', prompt: 'Add color markup to highlight key terms (green) and warnings (red)' },
      { label: 'Suggest image', prompt: 'Suggest a relevant photo or illustration with a search query' },
    ],
  },
  {
    label: 'Review',
    actions: [
      { label: 'Critique', prompt: 'Critique this slide — point out weaknesses and suggest improvements' },
      { label: 'Fact check', prompt: 'Verify claims and flag anything that needs a source or correction' },
    ],
  },
]

const QUESTION_AI_GROUPS = [
  {
    label: 'Generate',
    actions: [
      { label: 'Suggest question', prompt: 'Suggest a better question based on the course context' },
      { label: 'Generate options', prompt: 'Generate answer options for this question' },
      { label: 'Consequences', prompt: 'Write consequence messages explaining why each option is right or wrong' },
      { label: 'Add explanation', prompt: 'Generate an explanation shown after answering' },
      { label: 'Fill hint', prompt: 'Generate a helpful hint for this question' },
    ],
  },
  {
    label: 'Review',
    actions: [
      { label: 'Critique', prompt: 'Critique this question — is it clear, fair, and testing the right thing?' },
      { label: 'Fix grammar', prompt: 'Fix grammar and spelling in the question and options' },
    ],
  },
]

const OTHER_AI_GROUPS = [
  {
    label: 'Writing',
    actions: [
      { label: 'Fix grammar', prompt: 'Fix grammar and spelling errors' },
      { label: 'Make concise', prompt: 'Make the text more concise' },
      { label: 'Rewrite', prompt: 'Rewrite this content to be more engaging' },
    ],
  },
  {
    label: 'Review',
    actions: [
      { label: 'Critique', prompt: 'Critique this slide and suggest improvements' },
    ],
  },
]

const QUESTION_TYPES = [
  'single-choice-question',
  'true-false-question',
  'estimate-percentage-question',
]

const AI_ACTION_GROUPS = computed(() => {
  const entityType = props.block['entity-type']
  const isQuestion = QUESTION_TYPES.includes(entityType)
  const isText = entityType === 'text'

  if (isQuestion) {
    return QUESTION_AI_GROUPS
  }

  if (isText) {
    return TEXT_AI_GROUPS
  }

  return OTHER_AI_GROUPS
})

function handleAIQuickAction(actionPrompt: string) {
  // TODO: Connect to AI API
  aiSlidePrompt.value = actionPrompt
  showAIMenu.value = false
}

function handleAICustomPrompt() {
  // TODO: Connect to AI API for per-slide actions
  showAIMenu.value = false
  aiSlidePrompt.value = ''
}

// * Image insert for text segments

function addImageSegment() {
  const hasTextSegments = 'text-segments' in props.block

  if (hasTextSegments) {
    (props.block as any)['text-segments'].push('image-link:')
    segmentKeys.value.push(segmentKeyCounter++)
  }
}

function isImageSegment(segment: string): boolean {
  return segment.startsWith('image-link')
}

function getImageUrl(segment: string): string {
  return segment.replace(/^image-link(\[no-blur\])?:/, '')
}

function setImageUrl(segmentIndex: number, url: string) {
  const isEmpty = url.trim() === ''

  if (isEmpty) {
    ; (props.block as any)['text-segments'][segmentIndex] = ''
    return
  }

  const currentValue = (props.block as any)['text-segments'][segmentIndex]
  const hasNoBlur = currentValue.includes('[no-blur]')
  const prefix = hasNoBlur ? 'image-link[no-blur]:' : 'image-link:'

    ; (props.block as any)['text-segments'][segmentIndex] = prefix + url
}

function toggleSegmentToImage(segmentIndex: number) {
  const currentValue = (props.block as any)['text-segments'][segmentIndex]

    ; (props.block as any)['text-segments'][segmentIndex] = 'image-link:' + currentValue.trim()
}

function toggleSegmentToText(segmentIndex: number) {
  const currentValue = (props.block as any)['text-segments'][segmentIndex]

    ; (props.block as any)['text-segments'][segmentIndex] = getImageUrl(currentValue)
}

function isImageUrl(text: string): boolean {
  const trimmed = text.trim()

  return /^https?:\/\/.+\..+\.(jpg|jpeg|png|gif|webp|svg|avif|bmp|ico)(\?.*)?$/i.test(trimmed)
}

function handleSegmentUpdate(segmentIndex: number, newValue: string) {
  const oldValue = (props.block as any)['text-segments'][segmentIndex]
  const wasEmpty = oldValue.trim() === ''
  const isNewUrl = isImageUrl(newValue)

  if (wasEmpty && isNewUrl) {
    ; (props.block as any)['text-segments'][segmentIndex] = 'image-link:' + newValue.trim()
  } else {
    ; (props.block as any)['text-segments'][segmentIndex] = newValue
  }
}

// * Shift key state + hover tracking

const shiftHeld = ref(false)
const hoveredSegmentIndex = ref<number | null>(null)

function isInputFocused(): boolean {
  const target = document.activeElement as HTMLElement | null

  if (!target) {
    return false
  }

  const isEditable = target.tagName === 'INPUT' || target.tagName === 'TEXTAREA' || target.isContentEditable

  return isEditable
}

function handleShiftDown(event: KeyboardEvent) {
  if (event.key === 'Escape') {
    ; (document.activeElement as HTMLElement)?.blur()
    return
  }

  if (event.key === 'Shift' && !isInputFocused()) {
    shiftHeld.value = true
  }
}

function handleShiftUp(event: KeyboardEvent) {
  if (event.key === 'Shift') {
    shiftHeld.value = false
  }
}

function handleClickOutside(event: MouseEvent) {
  const target = event.target as HTMLElement
  const isEditable = target.tagName === 'INPUT' || target.tagName === 'TEXTAREA' || target.isContentEditable || target.closest('[contenteditable]') || target.closest('.ProseMirror')

  if (!isEditable) {
    (document.activeElement as HTMLElement)?.blur()
  }
}

// * Drag-and-drop for text segments

const segmentsContainerRef = ref<HTMLElement | null>(null)
let segmentsSortable: Sortable | null = null

function initSegmentsSortable() {
  if (segmentsSortable) {
    segmentsSortable.destroy()
    segmentsSortable = null
  }

  const container = segmentsContainerRef.value

  if (!container) {
    return
  }

  segmentsSortable = Sortable.create(container, {
    handle: '.segment-drag-handle',
    animation: 150,
    ghostClass: 'sortable-ghost',
    dragClass: '',
    onEnd(event) {
      const oldIndex = event.oldIndex
      const newIndex = event.newIndex
      const hasValidIndices = oldIndex !== undefined && newIndex !== undefined
      const isSamePosition = oldIndex === newIndex

      if (!hasValidIndices || isSamePosition) {
        return
      }

      // Revert DOM — let Vue handle updates
      const parent = event.from
      const movedNode = event.item

      parent.removeChild(movedNode)

      const referenceNode = parent.children[oldIndex!]

      if (referenceNode) {
        parent.insertBefore(movedNode, referenceNode)
      } else {
        parent.appendChild(movedNode)
      }

      // Update text-segments array
      const segments = (props.block as any)['text-segments']
      const movedSegment = segments.splice(oldIndex!, 1)[0]
      segments.splice(newIndex!, 0, movedSegment)

      // Update keys in sync
      const movedKey = segmentKeys.value.splice(oldIndex!, 1)[0]
      segmentKeys.value.splice(newIndex!, 0, movedKey)
    },
  })
}

watch(segmentsContainerRef, (el) => {
  if (el) {
    initSegmentsSortable()
    window.addEventListener('keydown', handleShiftDown)
    window.addEventListener('keyup', handleShiftUp)
    window.addEventListener('mousedown', handleClickOutside)
  }
})

onUnmounted(() => {
  if (segmentsSortable) {
    segmentsSortable.destroy()
  }

  window.removeEventListener('keydown', handleShiftDown)
  window.removeEventListener('keyup', handleShiftUp)
  window.removeEventListener('mousedown', handleClickOutside)
})

function moveSegmentUp(segmentIndex: number) {
  const segments = (props.block as any)['text-segments']
  const isFirst = segmentIndex === 0

  if (isFirst) {
    return
  }

  const moved = segments.splice(segmentIndex, 1)[0]
  segments.splice(segmentIndex - 1, 0, moved)

  const movedKey = segmentKeys.value.splice(segmentIndex, 1)[0]
  segmentKeys.value.splice(segmentIndex - 1, 0, movedKey)
}

function moveSegmentDown(segmentIndex: number) {
  const segments = (props.block as any)['text-segments']
  const isLast = segmentIndex >= segments.length - 1

  if (isLast) {
    return
  }

  const moved = segments.splice(segmentIndex, 1)[0]
  segments.splice(segmentIndex + 1, 0, moved)

  const movedKey = segmentKeys.value.splice(segmentIndex, 1)[0]
  segmentKeys.value.splice(segmentIndex + 1, 0, movedKey)
}

// * Guidelines text per entity type

const GUIDELINES: Record<string, string> = {
  'text': 'Use short, punchy sentences. Each segment = one thought. Use color markup for key terms (green) and warnings (red). Include image-link: for visuals.',
  'single-choice-question': 'Straight to the point. Each option needs a consequence-message explaining why right/wrong. Include a hint.',
  'true-false-question': 'Write a statement, not a question. The reader decides if it is true or false. Consequence messages should explain the reasoning.',
  'estimate-percentage-question': 'Use real statistics. Let the reader guess before revealing the answer.',
  'emotional-slide': 'Short motivational pause between sections. Keep it to one sentence.',
  'reflection': 'Personal application prompt. Include 3-4 thinking points.',
  'quote': 'Memorable insight from the author. Keep it impactful.',
}

const currentGuideline = computed(() => {
  const entityType = props.block['entity-type']

  return GUIDELINES[entityType] ?? ''
})
</script>

<template>
  <div class="flex flex-col gap-6">
    <!-- Header with badge + AI + guide -->
    <div class="flex items-center gap-2">
      <Badge variant="secondary">{{ entityLabel }}</Badge>

      <div class="flex-1" />

      <!-- Raw text edit toggle -->
      <Button
        v-if="'text-segments' in block"
        variant="outline"
        size="sm"
        class="h-7 text-xs"
        @click="showRawTextEditor ? (showRawTextEditor = false) : enterRawTextMode()"
      >
        {{ showRawTextEditor ? 'Segments' : 'Edit' }}
      </Button>

      <!-- AI actions -->
      <Popover v-model:open="showAIMenu">
        <PopoverTrigger as-child>
          <Button variant="outline" size="icon" class="h-7 w-7 border-current" :style="{ color: entityColor, backgroundColor: `color-mix(in srgb, ${entityColor} 6%, transparent)` }">
            <Sparkles class="h-3.5 w-3.5" />
          </Button>
        </PopoverTrigger>
        <PopoverContent align="end" class="w-80 p-3">
          <div class="flex flex-col gap-3">
            <!-- Grouped quick action pills -->
            <div v-for="(group, groupIndex) in AI_ACTION_GROUPS" :key="group.label" class="flex flex-col gap-2">
              <Separator v-if="groupIndex > 0" />

              <span class="text-xs font-medium uppercase tracking-wider" :style="{ color: entityColor }">{{ group.label }}</span>

              <div class="flex flex-wrap gap-2">
                <Button
                  v-for="action in group.actions"
                  :key="action.label"
                  variant="outline"
                  size="sm"
                  class="h-7 px-2.5 text-xs rounded-full"
                  @click="handleAIQuickAction(action.prompt)"
                >
                  {{ action.label }}
                </Button>
              </div>
            </div>

            <!-- Custom prompt -->
            <div class="flex gap-2">
              <Input
                v-model="aiSlidePrompt"
                placeholder="Ask anything..."
                class="flex-1 h-8 text-xs"
                @keydown.enter="handleAICustomPrompt"
              />
              <Button variant="ghost" size="icon" class="shrink-0 h-8 w-8" @click="handleAICustomPrompt">
                <Sparkles class="h-3.5 w-3.5" />
              </Button>
            </div>
          </div>
        </PopoverContent>
      </Popover>

      <!-- Guide -->
      <Popover v-if="currentGuideline" v-model:open="showGuidelinesDialog">
        <PopoverTrigger as-child>
          <Button variant="outline" size="icon" class="h-7 w-7">
            <BookOpen class="h-3.5 w-3.5" />
          </Button>
        </PopoverTrigger>
        <PopoverContent align="end" class="w-80">
          <p class="text-sm text-muted-foreground leading-relaxed">{{ currentGuideline }}</p>
        </PopoverContent>
      </Popover>
    </div>

    <Separator />

    <!-- Text segments -->
    <div v-if="'text-segments' in block" class="flex flex-col gap-4">
      <!-- Raw text edit mode -->
      <div v-if="showRawTextEditor" class="flex flex-col gap-4">
        <Textarea
          v-model="rawTextInput"
          placeholder="Paste text here... Each line becomes a segment."
          class="min-h-[200px] text-sm break-words whitespace-pre-wrap !field-sizing-normal"
        />

        <Button variant="ghost" class="w-full" @click="handleConvertRawText">
          Convert
        </Button>
      </div>

      <!-- Segment editor -->
      <template v-else>
      <div class="flex items-center justify-between">
        <label class="text-sm text-muted-foreground">Text Segments</label>
        <div class="flex items-center gap-1">
          <Button v-if="deletedSegmentStack.length > 0" variant="ghost" size="icon" class="h-8 w-8" @click="undoDeleteSegment"><Undo2 class="h-4 w-4" /></Button>
          <Button variant="ghost" size="icon" class="h-8 w-8" @click="addImageSegment"><ImageIcon class="h-4 w-4" /></Button>
          <Button variant="ghost" size="icon" class="h-8 w-8" @click="addTextSegment"><Plus class="h-4 w-4" /></Button>
        </div>
      </div>

      <div ref="segmentsContainerRef" class="flex flex-col gap-4">
      <div
        v-for="(_, segmentIndex) in (block as any)['text-segments']"
        :key="getSegmentKey(Number(segmentIndex))"
        class="relative"
        @mouseenter="hoveredSegmentIndex = Number(segmentIndex)"
        @mouseleave="hoveredSegmentIndex = null"
      >
        <!-- Content row -->
        <div class="flex gap-1 items-stretch">
          <!-- Input column -->
          <div class="flex-1 min-w-0 flex flex-col gap-2">
            <!-- Text input (rich text for all segments) -->
            <div class="relative">
              <RichTextSegment
                :model-value="isImageSegment((block as any)['text-segments'][segmentIndex]) ? getImageUrl((block as any)['text-segments'][segmentIndex]) : (block as any)['text-segments'][segmentIndex]"
                :class="shiftHeld && hoveredSegmentIndex === Number(segmentIndex) ? 'opacity-50' : ''"
                @update:model-value="(val: string) => isImageSegment((block as any)['text-segments'][segmentIndex]) ? setImageUrl(Number(segmentIndex), val) : handleSegmentUpdate(Number(segmentIndex), val)"
              />

              <!-- Controls overlay on the input -->
              <div v-if="shiftHeld && hoveredSegmentIndex === Number(segmentIndex)" class="absolute inset-0 z-10 flex items-center justify-center gap-1 backdrop-blur-sm rounded-md">
                <Button variant="ghost" size="icon" class="h-8 w-8" @click="removeTextSegment(Number(segmentIndex))">
                  <Minus class="h-4 w-4" />
                </Button>

                <Button
                  v-if="isImageSegment((block as any)['text-segments'][segmentIndex])"
                  variant="ghost" size="icon" class="h-8 w-8"
                  @click="toggleSegmentToText(Number(segmentIndex))"
                >
                  <Type class="h-4 w-4" />
                </Button>

                <Button
                  v-else
                  variant="ghost" size="icon" class="h-8 w-8"
                  @click="toggleSegmentToImage(Number(segmentIndex))"
                >
                  <ImageIcon class="h-4 w-4" />
                </Button>
              </div>
            </div>

            <!-- Image preview -->
            <img
              v-if="isImageSegment((block as any)['text-segments'][segmentIndex]) && getImageUrl((block as any)['text-segments'][segmentIndex]).length > 0"
              :src="getImageUrl((block as any)['text-segments'][segmentIndex])"
              class="w-full max-h-32 object-contain rounded-md border border-border mt-2 pointer-events-none select-none"
            />

            <!-- Insert after — only when Shift held + hovered -->
            <div
              v-if="shiftHeld && hoveredSegmentIndex === Number(segmentIndex)"
              class="border border-dashed border-border rounded-md flex items-center justify-center h-12 cursor-pointer hover:border-foreground/30 transition-colors mt-2 group/insert"
              @click="insertTextSegmentAfter(Number(segmentIndex))"
            >
              <Plus class="h-4 w-4 text-border group-hover/insert:text-foreground/30 transition-colors" />
            </div>
          </div>

          <!-- Drag handle -->
          <div class="segment-drag-handle shrink-0 w-10 flex items-center justify-center cursor-grab active:cursor-grabbing text-muted-foreground hover:text-foreground transition-colors">
            <GripVertical class="h-5 w-5" />
          </div>
        </div>
      </div>
      </div>
      </template>

    </div>

    <!-- Question -->
    <div v-if="'question' in block" class="flex flex-col gap-2">
      <label class="text-sm text-muted-foreground">Question</label>
      <Textarea v-model="(block as any).question" placeholder="Question text..." />
    </div>

    <!-- True/False options — compact row -->
    <div v-if="block['entity-type'] === 'true-false-question' && 'options' in block" class="flex flex-col gap-2">
      <label class="text-sm text-muted-foreground">Answer</label>

      <div class="flex flex-col gap-4">
        <div
          v-for="(option, optionIndex) in block.options"
          :key="(option as any)._uid ?? optionIndex"
          class="flex flex-col gap-2"
        >
          <div class="flex gap-2 items-center">
            <Input v-model="option.text" :placeholder="optionIndex === 0 ? 'True' : 'False'" class="flex-1" />

            <Checkbox
              v-if="'correct-answer-indices' in block"
              :checked="isCorrectAnswer(Number(optionIndex))"
              class="h-9 w-9 rounded-lg data-[state=checked]:bg-success data-[state=checked]:border-success"
              @update:checked="() => toggleCorrectAnswer(Number(optionIndex))"
            />
          </div>

          <Input
            v-model="option['consequence-message']"
            placeholder="Consequence message"
            variant="subtle"
          />
        </div>
      </div>

      <p
        v-if="'correct-answer-indices' in block && (block as any)['correct-answer-indices'].length === 0"
        class="text-xs text-primary italic"
      >Select the correct answer</p>
    </div>

    <!-- Options with correct answer checkboxes -->
    <div v-if="block['entity-type'] !== 'true-false-question' && block['entity-type'] !== 'estimate-percentage-question' && 'options' in block && block.options.length > 0" class="flex flex-col gap-2">
      <div class="flex items-center justify-between">
        <label class="text-sm text-muted-foreground">Options</label>
        <Button variant="ghost" size="icon" class="h-8 w-8" @click="addOption"><Plus class="h-4 w-4" /></Button>
      </div>

      <TransitionGroup tag="div" name="reorder-list" class="flex flex-col gap-4">
        <div
          v-for="(option, optionIndex) in block.options"
          :key="(option as any)._uid ?? optionIndex"
          class="flex gap-2 items-stretch"
        >
          <!-- Minus / Plus column -->
          <div class="flex flex-col shrink-0 items-center self-stretch">
            <Button
              variant="ghost"
              size="icon"
              class="flex-1 w-8 rounded-b-none hover:bg-muted hover:text-foreground"
              @click="removeOption(Number(optionIndex))"
            >
              <Minus class="h-4 w-4" />
            </Button>

            <Button variant="ghost" size="icon" class="flex-1 w-8 rounded-t-none text-muted-foreground opacity-0 hover:opacity-100 transition-opacity" @click="insertOptionAfter(Number(optionIndex))">
              <Plus class="h-4 w-4" />
            </Button>
          </div>

          <!-- Arrows column -->
          <div class="flex flex-col shrink-0 items-center justify-center self-stretch">
            <Button variant="ghost" size="icon" class="flex-1 w-8 rounded-b-none" @click="moveOptionUp(Number(optionIndex))"><ChevronUp class="h-4 w-4" /></Button>
            <Button variant="ghost" size="icon" class="flex-1 w-8 rounded-t-none" @click="moveOptionDown(Number(optionIndex))"><ChevronDown class="h-4 w-4" /></Button>
          </div>

          <!-- Option fields -->
          <div class="flex flex-col gap-2 flex-1 min-w-0">
            <Input v-model="option.text" :placeholder="`Option ${Number(optionIndex) + 1}`" />

            <Input
              v-if="'consequence-message' in option || block['entity-type'] === 'single-choice-question'"
              v-model="option['consequence-message']"
              placeholder="Consequence message"
              variant="subtle"
            />
          </div>

          <!-- Correct answer checkbox -->
          <Checkbox
            v-if="'correct-answer-indices' in block"
            :checked="isCorrectAnswer(Number(optionIndex))"
            class="self-start mt-0.5 h-9 w-9 rounded-lg data-[state=checked]:bg-success data-[state=checked]:border-success"
            @update:checked="() => toggleCorrectAnswer(Number(optionIndex))"
          />
        </div>
      </TransitionGroup>

      <p
        v-if="'correct-answer-indices' in block && (block as any)['correct-answer-indices'].length === 0"
        class="text-xs text-primary italic"
      >Select at least one correct answer</p>
    </div>

    <!-- Explanation -->
    <div v-if="'explanation' in block" class="flex flex-col gap-2">
      <label class="text-sm text-muted-foreground">Explanation</label>
      <Textarea v-model="(block as any).explanation" placeholder="Shown after answering..." />
    </div>

    <!-- Hint -->
    <div v-if="'hint' in block" class="flex flex-col gap-2">
      <label class="text-sm text-muted-foreground">Hint</label>
      <Input v-model="(block as any).hint" placeholder="Hint..." variant="subtle" />
    </div>

    <!-- Estimate percentage fields -->
    <div v-if="block['entity-type'] === 'estimate-percentage-question'" class="flex flex-col gap-4">
      <div class="flex flex-col gap-2">
        <label class="text-sm text-muted-foreground">Correct Percentage</label>
        <div class="flex items-center gap-3">
          <input
            type="range"
            min="0"
            max="100"
            :value="(block as any)['correct-answer-indices']?.[0] ?? 50"
            class="flex-1 accent-primary"
            @input="(e: any) => { (block as any)['correct-answer-indices'] = [Number(e.target.value)] }"
          />
          <span class="text-sm font-mono w-10 text-right tabular-nums">{{ (block as any)['correct-answer-indices']?.[0] ?? 50 }}%</span>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <label class="text-sm text-muted-foreground">Close Threshold</label>
        <div class="flex items-center gap-3">
          <input
            type="range"
            min="1"
            max="50"
            :value="(block as any)['close-threshold'] ?? 10"
            class="flex-1 accent-primary"
            @input="(e: any) => { (block as any)['close-threshold'] = Number(e.target.value) }"
          />
          <span class="text-sm font-mono w-10 text-right tabular-nums">±{{ (block as any)['close-threshold'] ?? 10 }}%</span>
        </div>
      </div>
    </div>

    <!-- Emotional slide fields -->
    <div v-if="block['entity-type'] === 'emotional-slide'" class="flex flex-col gap-4">
      <div class="flex flex-col gap-2">
        <label class="text-sm text-muted-foreground">Text</label>
        <Input v-model="(block as any).text" placeholder="Motivational message..." />
      </div>

      <div class="flex flex-col gap-2">
        <label class="text-sm text-muted-foreground">Icon</label>
        <Input v-model="(block as any).icon" placeholder="check, star, progress..." />
      </div>
    </div>

    <!-- Reflection fields -->
    <div v-if="block['entity-type'] === 'reflection'" class="flex flex-col gap-4">
      <div class="flex flex-col gap-2">
        <label class="text-sm text-muted-foreground">Prompt</label>
        <Textarea v-model="(block as any).prompt" placeholder="Reflection prompt..." />
      </div>

      <div class="flex flex-col gap-2">
        <label class="text-sm text-muted-foreground">Thinking Points</label>

        <div
          v-for="(_, pointIndex) in (block as any)['thinking-points']"
          :key="pointIndex"
          class="flex gap-2"
        >
          <Input
            v-model="(block as any)['thinking-points'][pointIndex]"
            :placeholder="`Point ${Number(pointIndex) + 1}`"
          />

          <Button
            variant="ghost"
            size="icon"
            class="shrink-0 h-8 w-8 hover:bg-muted hover:text-foreground"
            @click="removeThinkingPoint(Number(pointIndex))"
          >
            <Minus class="h-4 w-4" />
          </Button>
        </div>

        <Button variant="outline" class="w-full" @click="addThinkingPoint"><PlusCircle class="h-4 w-4" /></Button>
      </div>
    </div>

    <!-- Quote fields -->
    <div v-if="block['entity-type'] === 'quote'" class="flex flex-col gap-4">
      <div class="flex flex-col gap-2">
        <label class="text-sm text-muted-foreground">Quote</label>
        <Textarea v-model="(block as any).quote" placeholder="The quote text..." />
      </div>

      <div class="flex flex-col gap-2">
        <label class="text-sm text-muted-foreground">Author</label>
        <Input v-model="(block as any).author" placeholder="Author name" />
      </div>
    </div>

  </div>
</template>
