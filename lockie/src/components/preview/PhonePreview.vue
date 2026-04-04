<script setup lang="ts">
// Phone-shaped preview — renders swipes like the Dart app
// Progressive text reveal, tap to advance

import { computed, ref, watch, onMounted, onUnmounted } from 'vue'
import { useCourseStore } from '@/stores/CourseStore'
import type { Swipe } from '@/types/Course'
import { ENTITY_TYPE_LABELS, type EntityType } from '@/types/Course'
import { Button } from '@/components/ui/button'
import { Eye } from 'lucide-vue-next'

const store = useCourseStore()

// * Computed

const swipes = computed(() => store.activePackage?.content ?? [])
const hasNoSwipes = computed(() => swipes.value.length === 0)
const currentIndex = computed(() => store.activeSwipeIndex ?? 0)

const currentSwipe = computed<Swipe | null>(() => {
  return swipes.value[currentIndex.value] ?? null
})

const isTextSwipe = computed(() => {
  const swipe = currentSwipe.value

  if (!swipe) {
    return false
  }

  const entityType = (swipe as any)['entity-type']

  return entityType === 'text'
})

const textSegments = computed<string[]>(() => {
  const swipe = currentSwipe.value
  const hasSegments = swipe && 'text-segments' in swipe

  if (!hasSegments) {
    return []
  }

  return [...(swipe as any)['text-segments']]
})

const progressRatio = computed(() => {
  const total = swipes.value.length
  const isEmpty = total === 0

  if (isEmpty) {
    return 0
  }

  return (currentIndex.value + 1) / total
})

const courseColor = computed(() => {
  return store.activeCourse?.color ?? 'var(--muted-foreground)'
})

// * Resolve markup colors from CSS variables

function getCssColor(varName: string): string {
  return getComputedStyle(document.documentElement).getPropertyValue(varName).trim()
}

const markupRedColor = computed(() => getCssColor('--markup-red'))
const markupGreenColor = computed(() => getCssColor('--markup-green'))

// * Progressive text state

const activeSegmentIndex = ref(0)
const revealedCharPosition = ref(-1)
const isRevealing = ref(false)
let revealTimer: ReturnType<typeof setInterval> | null = null

// * Watchers

watch(currentIndex, () => {
  resetAndStartReveal()
})

watch(swipes, () => {
  const isNotRevealing = !isRevealing.value

  if (isNotRevealing) {
    revealAllInstantly()
  }
}, { deep: true })

onMounted(() => {
  resetAndStartReveal()
})

onUnmounted(() => {
  stopRevealTimer()
})

// * Reveal logic

function resetAndStartReveal() {
  stopRevealTimer()

  activeSegmentIndex.value = 0
  revealedCharPosition.value = -1

  const hasTextContent = isTextSwipe.value && textSegments.value.length > 0

  if (hasTextContent) {
    startSegmentReveal()
  } else {
    revealAllInstantly()
  }
}

function startSegmentReveal() {
  stopRevealTimer()

  // Skip image segments — reveal them instantly and move to next
  const currentSegment = textSegments.value[activeSegmentIndex.value] ?? ''
  const isImage = isImageSegment(currentSegment)

  if (isImage) {
    // Image is revealed by being at activeSegmentIndex, no animation needed
    stopRevealTimer()
    return
  }

  revealedCharPosition.value = -1
  isRevealing.value = true

  revealTimer = setInterval(() => {
    const segmentText = getCleanSegmentText(activeSegmentIndex.value)
    const isSegmentComplete = revealedCharPosition.value >= segmentText.length - 1

    if (isSegmentComplete) {
      stopRevealTimer()
      return
    }

    revealedCharPosition.value++
  }, 15)
}

function stopRevealTimer() {
  if (revealTimer) {
    clearInterval(revealTimer)
    revealTimer = null
  }

  isRevealing.value = false
}

function revealAllInstantly() {
  stopRevealTimer()

  activeSegmentIndex.value = textSegments.value.length
  revealedCharPosition.value = 99999
}

// * Tap handler

function handleContentTap() {
  const isNotTextSwipe = !isTextSwipe.value

  // Non-text swipes: do nothing, navigation is via the slide list
  if (isNotTextSwipe) {
    return
  }

  // All segments already revealed: reset and start over
  const isAllRevealed = activeSegmentIndex.value >= textSegments.value.length

  if (isAllRevealed) {
    resetAndStartReveal()
    return
  }

  const hasMoreSegments = activeSegmentIndex.value < textSegments.value.length - 1

  if (hasMoreSegments) {
    activeSegmentIndex.value++
    startSegmentReveal()
    return
  }

  // Last segment completed: reveal all
  revealAllInstantly()
}

function completeCurrentSegment() {
  stopRevealTimer()

  const segmentText = getCleanSegmentText(activeSegmentIndex.value)

  revealedCharPosition.value = segmentText.length
}

// * Text rendering helpers

function getCleanSegmentText(segmentIdx: number): string {
  const segment = textSegments.value[segmentIdx] ?? ''

  return segment.replace(/<c:[gr]>|<\/c:[gr]>/g, '')
}

function isSegmentRevealed(segmentIdx: number): boolean {
  return segmentIdx < activeSegmentIndex.value
}

function isSegmentActive(segmentIdx: number): boolean {
  return segmentIdx === activeSegmentIndex.value
}

function isSegmentHidden(segmentIdx: number): boolean {
  return segmentIdx > activeSegmentIndex.value
}

function shouldBlurSegment(segmentIdx: number): boolean {
  const isCompleted = isSegmentRevealed(segmentIdx)
  const isAllRevealed = activeSegmentIndex.value >= textSegments.value.length

  return isCompleted && !isAllRevealed
}

function getRenderedSegment(segment: string, segmentIdx: number): string {
  const isFullyRevealed = isSegmentRevealed(segmentIdx)

  if (isFullyRevealed) {
    return renderColorMarkup(segment)
  }

  const isActive = isSegmentActive(segmentIdx)

  if (isActive) {
    return getPartiallyRevealedHtml(segment, revealedCharPosition.value)
  }

  return `<span style="color: transparent;">${stripMarkup(segment)}</span>`
}

function getPartiallyRevealedHtml(segment: string, charPosition: number): string {
  const cleanText = stripMarkup(segment)
  const revealedCount = Math.min(charPosition + 1, cleanText.length)
  const hiddenPart = cleanText.substring(revealedCount)

  const visibleHtml = applyMarkupToSubstring(segment, revealedCount)
  const hiddenHtml = `<span style="color: transparent;">${hiddenPart}</span>`

  return visibleHtml + hiddenHtml
}

function applyMarkupToSubstring(originalSegment: string, visibleChars: number): string {
  let result = ''
  let cleanPos = 0
  let idx = 0

  while (idx < originalSegment.length && cleanPos < visibleChars) {
    const openMatch = originalSegment.substring(idx).match(/^<c:([gr])>/)

    if (openMatch) {
      const color = openMatch[1] === 'r' ? markupRedColor.value : markupGreenColor.value

      result += `<span style="color: ${color}; font-weight: 600;">`
      idx += openMatch[0].length
      continue
    }

    const closeMatch = originalSegment.substring(idx).match(/^<\/c:[gr]>/)

    if (closeMatch) {
      result += '</span>'
      idx += closeMatch[0].length
      continue
    }

    const isLastChar = cleanPos === visibleChars - 1

    if (isLastChar) {
      result += `<span class="char-reveal">${originalSegment[idx]}</span>`
    } else {
      result += originalSegment[idx]
    }

    cleanPos++
    idx++
  }

  const openTags = (result.match(/<span/g) || []).length
  const closeTags = (result.match(/<\/span>/g) || []).length
  const unclosed = openTags - closeTags

  for (let tagIdx = 0; tagIdx < unclosed; tagIdx++) {
    result += '</span>'
  }

  return result
}

function renderColorMarkup(text: string): string {
  const red = markupRedColor.value
  const green = markupGreenColor.value

  return text
    .replace(/<c:r>(.*?)<\/c:r>/g, `<span style="color: ${red}; font-weight: 600;">$1</span>`)
    .replace(/<c:g>(.*?)<\/c:g>/g, `<span style="color: ${green}; font-weight: 600;">$1</span>`)
}

function stripMarkup(text: string): string {
  return text.replace(/<c:[gr]>|<\/c:[gr]>/g, '')
}

// * Image detection

function isImageSegment(segment: string): boolean {
  return segment.startsWith('image-link')
}

function getImagePath(segment: string): string {
  return segment.replace(/image-link(\[no-blur\])?:/, '')
}

// * Navigation

function handlePrevious() {
  const hasPrevious = currentIndex.value > 0

  if (hasPrevious) {
    store.selectSwipe(currentIndex.value - 1)
  }
}

function handleNext() {
  const hasNext = currentIndex.value < swipes.value.length - 1

  if (hasNext) {
    store.selectSwipe(currentIndex.value + 1)
  }
}

function getLabel(entityType: string): string {
  return ENTITY_TYPE_LABELS[entityType as EntityType] ?? entityType
}
</script>

<template>
  <div class="flex flex-col items-center h-full gap-3">
    <!-- Phone frame -->
    <div class="w-[320px] h-[580px] rounded-[32px] border-2 border-border bg-card overflow-hidden flex flex-col shadow-lg">
      <!-- Progress bar -->
      <div class="h-1.5 bg-muted mx-4 mt-6 rounded-full overflow-hidden">
        <div
          class="h-full rounded-full transition-all duration-300"
          :style="{ width: `${progressRatio * 100}%`, backgroundColor: courseColor }"
        />
      </div>

      <!-- Swipe content — tap to reveal -->
      <div class="flex-1 flex flex-col overflow-auto cursor-pointer" @click="handleContentTap">
        <!-- Empty state -->
        <div v-if="hasNoSwipes" class="flex-1 flex items-center justify-center text-muted-foreground text-sm px-6 text-center cursor-default">
          No swipes yet
        </div>

        <!-- Active swipe -->
        <template v-else-if="currentSwipe">
          <div class="min-h-full p-6 flex flex-col gap-3">

            <!-- * Text / Intro / Outro — progressive reveal with blur -->
            <template v-if="isTextSwipe">
              <template v-for="(segment, segmentIndex) in textSegments" :key="segmentIndex">
                <!-- Image segments (never blurred) -->
                <img
                  v-if="isImageSegment(segment)"
                  :src="getImagePath(segment)"
                  class="rounded-lg segment-transition"
                  :class="{ 'segment-hidden': isSegmentHidden(Number(segmentIndex)) }"
                />

                <!-- Text segments -->
                <p
                  v-else
                  class="text-sm leading-relaxed text-card-foreground segment-transition"
                  :class="{ 'segment-hidden': isSegmentHidden(Number(segmentIndex)), 'segment-blurred': shouldBlurSegment(Number(segmentIndex)) }"
                  v-html="getRenderedSegment(segment, Number(segmentIndex))"
                />
              </template>
            </template>

            <!-- * Questions -->
            <template v-else-if="'question' in currentSwipe && 'options' in currentSwipe">
              <p class="text-sm font-medium text-card-foreground leading-relaxed" v-html="renderColorMarkup((currentSwipe as any).question)" />

              <div
                class="mt-2 gap-2"
                :class="(currentSwipe as any)['entity-type'] === 'true-false-question' ? 'flex' : 'flex flex-col'"
              >
                <div
                  v-for="(option, optionIndex) in (currentSwipe as any).options"
                  :key="optionIndex"
                  class="px-4 py-3 rounded-xl border text-sm text-card-foreground"
                  :class="(currentSwipe as any)['entity-type'] === 'true-false-question' ? 'flex-1 text-center' : ''"
                  :style="{ borderColor: (currentSwipe as any)['correct-answer-indices']?.includes(optionIndex) ? courseColor : 'var(--border)' }"
                >
                  {{ option.text }}
                </div>
              </div>
            </template>

            <!-- * Emotional Slide -->
            <template v-else-if="(currentSwipe as any)['entity-type'] === 'emotional-slide'">
              <div class="flex-1 flex flex-col items-center justify-center gap-4 py-12">
                <div class="text-3xl" :style="{ color: courseColor }">✦</div>
                <p class="text-sm text-center text-card-foreground/80 font-medium">{{ (currentSwipe as any).text }}</p>
              </div>
            </template>

            <!-- * Reflection -->
            <template v-else-if="(currentSwipe as any)['entity-type'] === 'reflection'">
              <p class="text-sm font-medium text-card-foreground leading-relaxed">{{ (currentSwipe as any).prompt }}</p>
              <div class="flex flex-col gap-2 mt-2">
                <div v-for="(point, pointIndex) in (currentSwipe as any)['thinking-points']" :key="pointIndex" class="px-4 py-3 rounded-xl bg-muted text-sm text-card-foreground/80">{{ point }}</div>
              </div>
            </template>

            <!-- * Quote -->
            <template v-else-if="(currentSwipe as any)['entity-type'] === 'quote'">
              <div class="flex-1 flex flex-col items-center justify-center gap-4 py-8">
                <div class="text-3xl" :style="{ color: courseColor }">"</div>
                <p class="text-sm text-center italic text-card-foreground leading-relaxed px-2">{{ (currentSwipe as any).quote }}</p>
                <p class="text-xs text-muted-foreground">— {{ (currentSwipe as any).author }}</p>
              </div>
            </template>

            <!-- * Fallback -->
            <template v-else>
              <p class="text-xs text-muted-foreground text-center py-8">{{ getLabel((currentSwipe as any)['entity-type']) }}</p>
            </template>
          </div>
        </template>
      </div>

      <!-- Bottom navigation -->
      <div class="h-12 border-t border-border flex items-center justify-between px-6 shrink-0">
        <button class="text-xs text-muted-foreground hover:text-card-foreground transition-colors" @click.stop="handlePrevious">← Back</button>
        <span class="text-xs text-muted-foreground">{{ currentIndex + 1 }} / {{ swipes.length }}</span>
        <button class="text-xs text-muted-foreground hover:text-card-foreground transition-colors" @click.stop="handleNext">Next →</button>
      </div>
    </div>

    <!-- Viewer controls -->
    <div v-if="isTextSwipe" class="w-[320px] flex items-center gap-4 text-xs text-muted-foreground">
      <Button variant="outline" size="icon" class="ml-auto h-9 w-9" @click="revealAllInstantly"><Eye class="h-4 w-4" /></Button>
    </div>
  </div>
</template>

<style scoped>
.segment-transition {
  transition: opacity 0.3s, filter 0.4s ease-out;
}

.segment-hidden {
  opacity: 0;
}

.segment-blurred {
  filter: blur(3px);
  opacity: 0.25;
}

@keyframes char-fade-in {
  from {
    opacity: 0;
  }

  to {
    opacity: 1;
  }
}

:deep(.char-reveal) {
  animation: char-fade-in 0.15s ease-out forwards;
}
</style>
