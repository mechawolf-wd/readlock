<script setup lang="ts">
// Editor form for a single content block
// Renders the correct fields based on entity-type

import { ref, computed } from 'vue'
import type { Swipe } from '@/types/Course'
import { ENTITY_TYPE_LABELS, type EntityType } from '@/types/Course'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { Checkbox } from '@/components/ui/checkbox'
import { Minus, Plus, PlusCircle, BookOpen, Sparkles, ImageIcon, ChevronUp, ChevronDown, Type } from 'lucide-vue-next'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from '@/components/ui/dialog'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover'
import RichTextSegment from '@/components/editor/RichTextSegment.vue'

const props = defineProps<{ block: Swipe }>()

const entityLabel = ENTITY_TYPE_LABELS[props.block['entity-type'] as EntityType] ?? props.block['entity-type']

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

function removeTextSegment(segmentIndex: number) {
  const hasTextSegments = 'text-segments' in props.block
  const hasMultipleSegments = hasTextSegments && props.block['text-segments'].length > 1

  if (hasMultipleSegments) {
    props.block['text-segments'].splice(segmentIndex, 1)
    segmentKeys.value.splice(segmentIndex, 1)
  }
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

const AI_ACTION_GROUPS = [
  {
    label: 'Writing',
    actions: [
      { label: 'Fix grammar', prompt: 'Fix grammar and spelling errors in this slide' },
      { label: 'Make concise', prompt: 'Make the text more concise without losing meaning' },
      { label: 'Make pop-scientific', prompt: 'Rewrite in an engaging popular science tone — vivid, surprising, accessible' },
      { label: 'Simplify language', prompt: 'Simplify the language for easier reading' },
    ],
  },
  {
    label: 'Structure',
    actions: [
      { label: 'Split into segments', prompt: 'Split the text into shorter, punchier segments' },
      { label: 'Add emphasis', prompt: 'Add color markup to highlight key terms' },
      { label: 'Suggest a photo', prompt: 'Suggest a relevant photo or illustration for this slide with a search query and description' },
    ],
  },
  {
    label: 'Generate',
    actions: [
      { label: 'Answer options', prompt: 'Generate answer options for this question' },
      { label: 'Explanation', prompt: 'Generate an explanation for the correct answer' },
      { label: 'Hint', prompt: 'Generate a helpful hint for this question' },
    ],
  },
  {
    label: 'Review',
    actions: [
      { label: 'Critique', prompt: 'Critique this slide — point out weaknesses, factual issues, and suggest improvements' },
      { label: 'Fact check', prompt: 'Verify the claims in this slide and flag anything that needs a source or correction' },
    ],
  },
]

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
  'single-choice-question': 'Test comprehension. Each option needs a consequence-message explaining why right/wrong. Include a hint.',
  'true-false-question': 'Test fact vs misconception. Consequence messages should explain the reasoning.',
  'estimate-percentage-question': 'Use real statistics. Let the reader guess before revealing the answer.',
  'fill-gap-question': 'Use ___ for blanks in the question. Options are the words to fill in.',
  'incorrect-statement-question': 'List 3+ statements. One or more are incorrect. Tests critical thinking.',
  'reflection-question': 'Open-ended. Focus on deeper understanding, not right/wrong.',
  'emotional-slide': 'Short motivational pause between sections. Keep it to one sentence.',
  'reflection': 'Personal application prompt. Include 3-4 thinking points.',
  'quote': 'Memorable insight from the author. Keep it impactful.',
  'skill-check': 'Marker before assessment questions. No content needed.',
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

      <!-- AI actions -->
      <Popover v-model:open="showAIMenu">
        <PopoverTrigger as-child>
          <Button variant="outline" size="sm" class="h-7 gap-1.5 text-xs">
            <Sparkles class="h-3 w-3" />
            AI
          </Button>
        </PopoverTrigger>
        <PopoverContent align="end" class="w-80 p-3">
          <div class="flex flex-col gap-3">
            <!-- Grouped quick action pills -->
            <div v-for="(group, groupIndex) in AI_ACTION_GROUPS" :key="group.label" class="flex flex-col gap-1.5">
              <Separator v-if="groupIndex > 0" />

              <span class="text-[10px] font-medium text-muted-foreground uppercase tracking-wider">{{ group.label }}</span>

              <div class="flex flex-wrap gap-1.5">
                <button
                  v-for="action in group.actions"
                  :key="action.label"
                  class="px-2.5 py-1 text-xs rounded-full border border-border hover:bg-accent hover:border-accent-foreground/20 transition-colors cursor-pointer"
                  @click="handleAIQuickAction(action.prompt)"
                >
                  {{ action.label }}
                </button>
              </div>
            </div>

            <!-- Custom prompt -->
            <div class="flex gap-1.5">
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

      <!-- Guide button -->
      <Dialog v-model:open="showGuidelinesDialog">
        <Button
          v-if="currentGuideline"
          variant="outline"
          size="sm"
          class="h-7 gap-1.5 text-xs"
          @click="showGuidelinesDialog = true"
        >
          <BookOpen class="h-3 w-3" />
          Guide
        </Button>

        <DialogContent class="max-w-sm">
          <DialogHeader>
            <DialogTitle>{{ entityLabel }} Guide</DialogTitle>
            <DialogDescription>Writing guidelines for this content type</DialogDescription>
          </DialogHeader>

          <p class="text-sm text-muted-foreground leading-relaxed">
            {{ currentGuideline }}
          </p>
        </DialogContent>
      </Dialog>
    </div>

    <Separator />

    <!-- Text segments -->
    <div v-if="'text-segments' in block" class="flex flex-col gap-4">
      <div class="flex items-center justify-between">
        <label class="text-sm text-muted-foreground">Text Segments</label>
        <div class="flex items-center gap-1">
          <Button variant="ghost" size="icon" class="h-8 w-8" @click="addImageSegment"><ImageIcon class="h-4 w-4" /></Button>
          <Button variant="ghost" size="icon" class="h-8 w-8" @click="addTextSegment"><Plus class="h-4 w-4" /></Button>
        </div>
      </div>

      <TransitionGroup tag="div" name="reorder-list" class="flex flex-col gap-4">
      <div
        v-for="(_, segmentIndex) in (block as any)['text-segments']"
        :key="getSegmentKey(Number(segmentIndex))"
        class="flex flex-col gap-1"
      >
        <div class="flex gap-1">
          <!-- Plus / Minus column -->
          <div class="flex flex-col shrink-0 items-center self-stretch">
            <Button
              variant="ghost"
              size="icon"
              class="flex-1 w-8 rounded-b-none hover:bg-destructive/10 hover:text-destructive"
              @click="removeTextSegment(Number(segmentIndex))"
            >
              <Minus class="h-4 w-4" />
            </Button>

            <Button variant="ghost" size="icon" class="flex-1 w-8 rounded-t-none text-muted-foreground opacity-0 hover:opacity-100 transition-opacity" @click="insertTextSegmentAfter(Number(segmentIndex))">
              <Plus class="h-4 w-4" />
            </Button>
          </div>

          <!-- Arrows column -->
          <div class="flex flex-col shrink-0 items-center justify-center self-stretch">
            <Button variant="ghost" size="icon" class="flex-1 w-8 rounded-b-none" @click="moveSegmentUp(Number(segmentIndex))"><ChevronUp class="h-4 w-4" /></Button>
            <Button variant="ghost" size="icon" class="flex-1 w-8 rounded-t-none" @click="moveSegmentDown(Number(segmentIndex))"><ChevronDown class="h-4 w-4" /></Button>
          </div>

          <!-- Image segment -->
          <div v-if="isImageSegment((block as any)['text-segments'][segmentIndex])" class="flex-1 flex flex-col gap-2.5">
            <Input
              :model-value="(block as any)['text-segments'][segmentIndex]"
              placeholder="image-link:https://..."
              class="text-xs font-mono"
              @update:model-value="(val: any) => { (block as any)['text-segments'][segmentIndex] = String(val) }"
            />

            <!-- Image preview -->
            <img
              v-if="(block as any)['text-segments'][segmentIndex].length > 11"
              :src="(block as any)['text-segments'][segmentIndex].replace(/image-link(\[no-blur\])?:/, '')"
              class="w-full max-h-32 object-contain rounded-md border border-border"
            />
          </div>

          <!-- Text segment (rich text) -->
          <RichTextSegment
            v-else
            :model-value="(block as any)['text-segments'][segmentIndex]"
            class="flex-1"
            @update:model-value="(val: string) => { (block as any)['text-segments'][segmentIndex] = val }"
          />
        </div>
      </div>
      </TransitionGroup>

    </div>

    <!-- Question -->
    <div v-if="'question' in block" class="flex flex-col gap-1.5">
      <label class="text-sm text-muted-foreground">Question</label>
      <Textarea v-model="(block as any).question" placeholder="Question text..." />
    </div>

    <!-- Options with correct answer checkboxes (draggable) -->
    <div v-if="'options' in block && block.options.length > 0" class="flex flex-col gap-4">
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
          <!-- Minus column -->
          <div class="flex flex-col shrink-0 items-center self-stretch">
            <Button
              variant="ghost"
              size="icon"
              class="flex-1 w-8 hover:bg-destructive/10 hover:text-destructive"
              @click="removeOption(Number(optionIndex))"
            >
              <Minus class="h-4 w-4" />
            </Button>
          </div>

          <!-- Arrows column -->
          <div class="flex flex-col shrink-0 items-center justify-center self-stretch">
            <Button variant="ghost" size="icon" class="flex-1 w-8 rounded-b-none" @click="moveOptionUp(Number(optionIndex))"><ChevronUp class="h-4 w-4" /></Button>
            <Button variant="ghost" size="icon" class="flex-1 w-8 rounded-t-none" @click="moveOptionDown(Number(optionIndex))"><ChevronDown class="h-4 w-4" /></Button>
          </div>

          <!-- Option fields -->
          <div class="flex flex-col gap-1 flex-1">
            <Input v-model="option.text" :placeholder="`Option ${Number(optionIndex) + 1}`" />

            <Input
              v-if="'consequence-message' in option || block['entity-type'] === 'single-choice-question'"
              v-model="option['consequence-message']"
              placeholder="Consequence message"
              class="text-xs !bg-transparent border-border italic text-muted-foreground"
            />
          </div>

          <!-- Correct answer checkbox -->
          <Checkbox
            v-if="'correct-answer-indices' in block"
            :checked="isCorrectAnswer(Number(optionIndex))"
            class="self-start h-9 w-9 rounded-lg data-[state=checked]:bg-green-600 data-[state=checked]:border-green-600"
            @update:checked="() => toggleCorrectAnswer(Number(optionIndex))"
          />
        </div>
      </TransitionGroup>
    </div>

    <!-- Explanation -->
    <div v-if="'explanation' in block" class="flex flex-col gap-1.5">
      <label class="text-sm text-muted-foreground">Explanation</label>
      <Textarea v-model="(block as any).explanation" placeholder="Shown after answering..." />
    </div>

    <!-- Hint -->
    <div v-if="'hint' in block" class="flex flex-col gap-1.5">
      <label class="text-sm text-muted-foreground">Hint</label>
      <Input v-model="(block as any).hint" placeholder="Hint..." class="text-xs !bg-transparent border-border italic text-muted-foreground" />
    </div>

    <!-- Emotional slide fields -->
    <div v-if="block['entity-type'] === 'emotional-slide'" class="flex flex-col gap-4">
      <div class="flex flex-col gap-1.5">
        <label class="text-sm text-muted-foreground">Text</label>
        <Input v-model="(block as any).text" placeholder="Motivational message..." />
      </div>

      <div class="flex flex-col gap-1.5">
        <label class="text-sm text-muted-foreground">Icon</label>
        <Input v-model="(block as any).icon" placeholder="check, star, progress..." />
      </div>
    </div>

    <!-- Reflection fields -->
    <div v-if="block['entity-type'] === 'reflection'" class="flex flex-col gap-4">
      <div class="flex flex-col gap-1.5">
        <label class="text-sm text-muted-foreground">Prompt</label>
        <Textarea v-model="(block as any).prompt" placeholder="Reflection prompt..." />
      </div>

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
          class="shrink-0 h-8 w-8 hover:bg-destructive/10 hover:text-destructive"
          @click="removeThinkingPoint(Number(pointIndex))"
        >
          <Minus class="h-4 w-4" />
        </Button>
      </div>

      <Button variant="outline" class="w-full" @click="addThinkingPoint"><PlusCircle class="h-4 w-4" /></Button>
    </div>

    <!-- Quote fields -->
    <div v-if="block['entity-type'] === 'quote'" class="flex flex-col gap-4">
      <div class="flex flex-col gap-1.5">
        <label class="text-sm text-muted-foreground">Quote</label>
        <Textarea v-model="(block as any).quote" placeholder="The quote text..." />
      </div>

      <div class="flex flex-col gap-1.5">
        <label class="text-sm text-muted-foreground">Author</label>
        <Input v-model="(block as any).author" placeholder="Author name" />
      </div>
    </div>

  </div>
</template>
