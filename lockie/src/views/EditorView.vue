<script setup lang="ts">
// Main editor view — Accelerator → Segments → Packages → Swipes

import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { codeToHtml } from 'shiki'
import { useCourseStore } from '@/stores/CourseStore'
import { useAuthStore } from '@/stores/AuthStore'
import { useRouter } from 'vue-router'
import {
  ENTITY_TYPE_LABELS,
  ENTITY_TYPE_ICONS,
  ENTITY_TYPE_COLORS,
  ENTITY_TYPE_GROUPS,
  QUICK_ADD_TYPES,
  PREMADE_GENRES,
  type EntityType,
} from '@/types/Course'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Separator } from '@/components/ui/separator'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import { Switch } from '@/components/ui/switch'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover'
import { X, ChevronUp, ChevronDown, PlusCircle, Settings, Undo2, Code, LogOut, Download, Trash2 } from 'lucide-vue-next'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import ContentBlockEditor from '@/components/editor/ContentBlockEditor.vue'
import PhonePreview from '@/components/preview/PhonePreview.vue'
import VantaBackground from '@/components/VantaBackground.vue'
import courseJSON from '../../../readlock/assets/data/course_data.json'

// * Store and router

const store = useCourseStore()
const auth = useAuthStore()
const router = useRouter()

// * State

const showCourseConfigDialog = ref(false)
const showCourseSelectDialog = ref(false)
const showAddSwipeDialog = ref(false)
const showJsonView = ref(false)
const openSegmentSettingsIndex = ref<number | null>(null)
const openPackageSettingsIndex = ref<number | null>(null)

// * AI Creator state

const aiSources = ref<string[]>([''])
const aiSegmentCount = ref(3)
const aiLessonsPerSegment = ref(8)
const aiTone = ref('educational')
const aiSystemPrompt = ref('')
const aiChatMessages = ref<{ role: string; text: string }[]>([])
const aiChatInput = ref('')

const sidebarScrollRef = ref<HTMLElement | null>(null)

// * Sortable drag-and-drop for swipes

// * Computed

const hasActivePackage = computed(() => store.activePackage !== null)
const hasActiveCourse = computed(() => store.activeCourse !== null)
const hasActiveSegment = computed(() => store.activeSegment !== null)
const hasActiveSwipe = computed(() => store.activeSwipe !== null)

const availableGenres = computed(() => {
  const currentGenres = store.activeCourse?.genres ?? []

  return PREMADE_GENRES.filter((genre) => !currentGenres.includes(genre))
})

const formattedJson = computed(() => store.exportJSON())
const highlightedJson = ref('')

watch(formattedJson, async (json) => {
  highlightedJson.value = await codeToHtml(json, {
    lang: 'json',
    theme: 'github-dark-default',
  })
}, { immediate: true })

const totalSwipeCount = computed(() => {
  const course = store.activeCourse

  if (!course) {
    return 0
  }

  let total = 0

  for (const segment of course.segments) {
    for (const pkg of segment.lessons) {
      total += pkg.content.length
    }
  }

  return total
})

const totalPackageCount = computed(() => {
  const course = store.activeCourse

  if (!course) {
    return 0
  }

  let total = 0

  for (const segment of course.segments) {
    total += segment.lessons.length
  }

  return total
})

// * Lifecycle

onMounted(() => {
  const hasStoredData = store.loadFromStorage()

  if (!hasStoredData) {
    store.loadCourseData(courseJSON as any)
  }

  const hasCourses = store.courseData.courses.length > 0

  if (hasCourses) {
    store.selectCourse(0)
  }
})

// * Keyboard navigation — arrow up/down to browse segments, packages, swipes

type FocusPanel = 'segments' | 'packages' | 'swipes'

const activePanel = ref<FocusPanel>('swipes')

function handleKeyDown(event: KeyboardEvent) {
  const isArrowUp = event.key === 'ArrowUp'
  const isArrowDown = event.key === 'ArrowDown'
  const isArrowLeft = event.key === 'ArrowLeft'
  const isArrowRight = event.key === 'ArrowRight'
  const isSpace = event.key === ' '
  const isEnter = event.key === 'Enter'
  const isHandled = isArrowUp || isArrowDown || isArrowLeft || isArrowRight || isSpace || isEnter

  if (!isHandled) {
    return
  }

  // Skip if user is typing in an input/textarea/editor
  const target = event.target as HTMLElement
  const isEditable = target.tagName === 'INPUT' || target.tagName === 'TEXTAREA' || target.isContentEditable

  if (isEditable) {
    return
  }

  event.preventDefault()

  if (isEnter) {
    const isOnSwipes = activePanel.value === 'swipes'

    if (isOnSwipes) {
      activePanel.value = 'packages'
    } else {
      const hasSwipes = store.activePackage && store.activePackage.content.length > 0

      if (hasSwipes) {
        activePanel.value = 'swipes'
      }
    }

    return
  }

  if (isSpace) {
    const isOnPackages = activePanel.value === 'packages'
    const isOnSwipes = activePanel.value === 'swipes'
    const direction = event.shiftKey ? -1 : 1
    const wrap = !event.shiftKey

    if (isOnPackages) {
      navigatePackage(direction, wrap)
    } else if (isOnSwipes) {
      navigateSwipe(direction, wrap)
    }

    return
  }

  if (isArrowLeft) {
    activePanel.value = 'packages'
    return
  }

  if (isArrowRight) {
    const hasSwipes = store.activePackage && store.activePackage.content.length > 0

    if (hasSwipes) {
      activePanel.value = 'swipes'
    }

    return
  }

  const direction = isArrowUp ? -1 : 1

  if (activePanel.value === 'swipes') {
    navigateSwipe(direction)
  } else if (activePanel.value === 'packages') {
    navigatePackage(direction)
  } else if (activePanel.value === 'segments') {
    navigateSegment(direction)
  }
}

function navigateSwipe(direction: number, wrap = false) {
  const hasNoPackage = !store.activePackage

  if (hasNoPackage) {
    return
  }

  const total = store.activePackage!.content.length
  const currentIndex = store.activeSwipeIndex ?? -1
  let newIndex = currentIndex + direction

  if (wrap && newIndex >= total) {
    newIndex = 0
  }

  const isInBounds = newIndex >= 0 && newIndex < total

  if (isInBounds) {
    store.selectSwipe(newIndex)
  }
}

function navigatePackage(direction: number, wrap = false) {
  const hasNoSegment = !store.activeSegment

  if (hasNoSegment) {
    return
  }

  const total = store.activeSegment!.lessons.length
  let newIndex = store.activePackageIndex + direction

  const shouldWrapToFirst = wrap && newIndex >= total

  if (shouldWrapToFirst) {
    newIndex = 0

    nextTick(() => {
      const firstPackage = document.querySelector('[data-package-index="0"]')

      if (firstPackage) {
        firstPackage.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
      }
    })
  }

  const isInBounds = newIndex >= 0 && newIndex < total

  if (isInBounds) {
    store.selectPackage(newIndex)
  }
}

function navigateSegment(direction: number) {
  const hasNoCourse = !store.activeCourse

  if (hasNoCourse) {
    return
  }

  const newIndex = store.activeSegmentIndex + direction
  const isInBounds = newIndex >= 0 && newIndex < store.activeCourse!.segments.length

  if (isInBounds) {
    store.selectSegment(newIndex)
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeyDown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown)
})

// * Sync course color to CSS primary

const courseColor = computed(() => store.activeCourse?.color ?? '#dc2626')

watch(courseColor, (newColor) => {
  document.documentElement.style.setProperty('--primary', newColor)
  document.documentElement.style.setProperty('--ring', newColor)
}, { immediate: true })

// * Auto-select first swipe when switching packages

watch(() => store.activePackage, (pkg) => {
  const hasContent = pkg !== null && pkg.content.length > 0

  if (hasContent) {
    store.selectSwipe(0)
  }
})

// * Auto-scroll to active items

watch(() => store.activeSwipeIndex, () => {
  nextTick(() => {
    const activeIndex = store.activeSwipeIndex

    if (activeIndex === null) {
      return
    }

    const el = document.querySelector(`[data-swipe-index="${activeIndex}"]`) as HTMLElement

    if (el) {
      el.scrollIntoView({ block: 'nearest' })
    }
  })
})

watch(() => store.activePackageIndex, () => {
  nextTick(() => {
    const el = document.querySelector(`[data-package-index="${store.activePackageIndex}"]`) as HTMLElement

    if (el) {
      el.scrollIntoView({ block: 'nearest' })
    }
  })
})

// * Methods

function handleMoveSwipeUp() {
  const index = store.activeSwipeIndex
  const hasNoSelection = index === null || index === 0
  const hasNoPackage = !store.activePackage

  if (hasNoSelection || hasNoPackage) {
    return
  }

  const content = store.activePackage!.content
  const moved = content.splice(index, 1)[0]

  if (moved) {
    content.splice(index - 1, 0, moved)
    store.selectSwipe(index - 1)
  }
}

function handleMoveSwipeDown() {
  const index = store.activeSwipeIndex
  const hasNoPackage = !store.activePackage

  if (index === null || hasNoPackage) {
    return
  }

  const content = store.activePackage!.content
  const isLastItem = index >= content.length - 1

  if (isLastItem) {
    return
  }

  const moved = content.splice(index, 1)[0]

  if (moved) {
    content.splice(index + 1, 0, moved)
    store.selectSwipe(index + 1)
  }
}

function handleAddSwipe(entityType: EntityType) {
  store.addSwipe(entityType)
  showAddSwipeDialog.value = false
}

function handleExport() {
  const json = store.exportJSON()
  const blob = new Blob([json], { type: 'application/json' })
  const url = URL.createObjectURL(blob)

  const link = document.createElement('a')
  link.href = url
  link.download = 'course_data.json'
  link.click()

  URL.revokeObjectURL(url)
}

function handleAISendMessage() {
  const hasNoInput = aiChatInput.value.trim() === ''

  if (hasNoInput) {
    return
  }

  aiChatMessages.value.push({ role: 'user', text: aiChatInput.value })

  // TODO: Connect to AI API
  aiChatMessages.value.push({
    role: 'assistant',
    text: 'Course generation mockup — AI integration coming soon.',
  })

  aiChatInput.value = ''
}

function handleAIFillCourse() {
  // TODO: Connect to AI generation API
}

function handleLogout() {
  auth.logout()

  router.push('/')
}

function handleAddGenre(genre: string) {
  const isAlreadyAdded = store.activeCourse?.genres.includes(genre)

  if (store.activeCourse && !isAlreadyAdded) {
    store.activeCourse.genres.push(genre)
  }
}

function handleRemoveGenre(genreIndex: number) {
  if (store.activeCourse) {
    store.activeCourse.genres.splice(genreIndex, 1)
  }
}

function handleAddRelevantFor() {
  if (store.activeCourse) {
    store.activeCourse['relevant-for'].push('')
  }
}

function handleRemoveRelevantFor(itemIndex: number) {
  if (store.activeCourse) {
    store.activeCourse['relevant-for'].splice(itemIndex, 1)
  }
}

function handleAddSource() {
  aiSources.value.push('')
}

function handleRemoveSource(sourceIndex: number) {
  const hasMultiple = aiSources.value.length > 1

  if (hasMultiple) {
    aiSources.value.splice(sourceIndex, 1)
  }
}

function handleCreateNewCourse() {
  // TODO: Connect to course creation
  showCourseSelectDialog.value = false
}

function toggleJsonView() {
  showJsonView.value = !showJsonView.value
}

function isSegmentSelected(segmentIndex: number): boolean {
  return store.activeSegmentIndex === segmentIndex
}

function isPackageSelected(packageIndex: number): boolean {
  return store.activePackageIndex === packageIndex
}

function isSwipeSelected(swipeIndex: number): boolean {
  return store.activeSwipeIndex === swipeIndex
}

function getSwipeItemClass(isSelected: boolean): string {
  if (isSelected) {
    return ''
  }

  return 'hover:bg-muted'
}

function getSwipeItemStyle(swipe: any, isSelected: boolean): Record<string, string> {
  if (!isSelected) {
    return {}
  }

  const color = ENTITY_TYPE_COLORS[swipe['entity-type'] as EntityType]

  return {
    backgroundColor: color + '15',
    color: color,
  }
}

function getNavItemClass(isSelected: boolean): string {
  if (isSelected) {
    return ''
  }

  return 'hover:bg-muted'
}

function getNavItemStyle(isSelected: boolean): Record<string, string> {
  if (!isSelected) {
    return {}
  }

  return {
    backgroundColor: courseColor.value + '15',
    color: '#ffffff',
  }
}
</script>

<template>
  <div class="h-screen flex flex-col bg-background">
    <!-- Top bar -->
    <header class="h-14 border-b border-border shrink-0 relative overflow-hidden">
      <VantaBackground v-if="hasActiveCourse" :color="courseColor" />
      <div class="relative z-10 h-full flex items-center justify-between px-6">
      <div class="flex items-center gap-3">
        <!-- Logo -->
        <Dialog v-model:open="showCourseSelectDialog">
          <DialogTrigger as-child>
            <button class="text-lg font-bold text-white cursor-pointer hover:opacity-80 transition-opacity drop-shadow-sm">Lockie</button>
          </DialogTrigger>
          <DialogContent class="max-w-sm">
            <DialogHeader>
              <DialogTitle>Courses</DialogTitle>
            </DialogHeader>
            <div class="flex flex-col gap-2 pt-2">
              <div
                v-for="(course, courseIndex) in store.courseData.courses"
                :key="courseIndex"
                class="px-4 py-3 rounded-lg border border-border cursor-pointer hover:bg-accent transition-colors"
                @click="store.selectCourse(courseIndex); showCourseSelectDialog = false"
              >
                <div class="font-medium text-sm">{{ course.title }}</div>
                <div class="text-xs text-muted-foreground">{{ course.author }}</div>
              </div>
              <Separator />
              <Button variant="outline" class="w-full" @click="handleCreateNewCourse"><PlusCircle class="h-4 w-4" /></Button>
            </div>
          </DialogContent>
        </Dialog>
        <span class="text-sm text-white/60">for Readlock</span>
        <span v-if="hasActiveCourse" class="text-[10px] text-white/40">{{ store.activeCourse!.segments.length }} segments · {{ totalPackageCount }} packages · {{ totalSwipeCount }} swipes</span>
      </div>

      <div class="flex items-center gap-2">
        <Dialog v-model:open="showCourseConfigDialog">
          <DialogTrigger as-child>
            <Button v-if="hasActiveCourse" variant="ghost" size="icon" class="text-white/80 hover:text-white hover:bg-white/10"><Settings class="h-4 w-4" /></Button>
          </DialogTrigger>
          <DialogContent class="max-w-lg max-h-[80vh] overflow-auto">
            <DialogHeader><DialogTitle>Course Settings</DialogTitle></DialogHeader>
            <div v-if="hasActiveCourse" class="flex flex-col gap-5 pt-2">
              <div class="flex flex-col gap-1.5">
                <label class="text-sm text-muted-foreground">Title</label>
                <Input v-model="store.activeCourse!.title" />
              </div>
              <div class="flex flex-col gap-1.5">
                <label class="text-sm text-muted-foreground">Author</label>
                <Input v-model="store.activeCourse!.author" />
              </div>
              <div class="flex flex-col gap-1.5">
                <label class="text-sm text-muted-foreground">Description</label>
                <Textarea v-model="store.activeCourse!.description" class="min-h-[80px]" />
              </div>
              <div class="flex flex-col gap-1.5">
                <label class="text-sm text-muted-foreground">Theme Color</label>
                <div class="flex items-center gap-3">
                  <input type="color" :value="store.activeCourse!.color" class="w-10 h-10 rounded-md border border-border cursor-pointer" @input="(e: any) => store.activeCourse!.color = e.target.value" />
                  <Input v-model="store.activeCourse!.color" class="flex-1" />
                </div>
              </div>
              <div class="flex flex-col gap-2">
                <label class="text-sm text-muted-foreground">Relevant For</label>
                <div v-for="(_, itemIndex) in store.activeCourse!['relevant-for']" :key="itemIndex" class="flex gap-2">
                  <Input v-model="store.activeCourse!['relevant-for'][itemIndex]" class="flex-1 h-9" />
                  <Button variant="ghost" size="icon" class="shrink-0 h-8 w-8 hover:bg-destructive/10 hover:text-destructive" @click="handleRemoveRelevantFor(Number(itemIndex))"><X class="h-3.5 w-3.5" /></Button>
                </div>
                <Button variant="outline" class="w-full" @click="handleAddRelevantFor"><PlusCircle class="h-4 w-4" /></Button>
              </div>
              <div class="flex flex-col gap-2">
                <label class="text-sm text-muted-foreground">Genres</label>
                <div class="flex flex-wrap gap-2">
                  <Badge v-for="(genre, genreIndex) in store.activeCourse!.genres" :key="genre" variant="secondary" class="cursor-pointer hover:bg-destructive/20 gap-1" @click="handleRemoveGenre(genreIndex)">{{ genre }} <X class="h-3 w-3" /></Badge>
                </div>
                <div class="flex flex-wrap gap-1.5 pt-1">
                  <Badge v-for="genre in availableGenres" :key="genre" variant="outline" class="cursor-pointer hover:bg-accent" @click="handleAddGenre(genre)">+ {{ genre }}</Badge>
                </div>
              </div>
              <Separator />
              <Button variant="outline" class="w-full" @click="handleAIFillCourse">AI Fill</Button>
            </div>
          </DialogContent>
        </Dialog>
        <Button variant="ghost" size="icon" class="text-white/80 hover:text-white hover:bg-white/10" @click="handleExport"><Download class="h-4 w-4" /></Button>
        <Button variant="ghost" size="icon" class="text-white/80 hover:text-white hover:bg-white/10" @click="handleLogout"><LogOut class="h-4 w-4" /></Button>
      </div>
      </div>
    </header>

    <!-- JSON View -->
    <div v-if="showJsonView" class="flex flex-1 overflow-hidden">
      <div class="flex-1 flex flex-col overflow-hidden border-r border-border">
        <div class="p-4 border-b border-border flex items-center gap-4 shrink-0">
          <span class="text-sm font-medium">Course JSON</span>
          <span v-if="hasActiveCourse" class="text-[10px] text-muted-foreground">{{ (formattedJson.length / 1024).toFixed(1) }} KB</span>
        </div>
        <div class="flex-1 overflow-auto [&_pre]:p-6 [&_pre]:text-xs [&_pre]:leading-relaxed [&_pre]:min-h-full [&_pre]:overflow-x-auto [&_code]:whitespace-pre" v-html="highlightedJson" />
        <div class="p-4 border-t border-border flex gap-2 shrink-0">
          <Button variant="outline" class="w-full h-9 text-xs" @click="toggleJsonView">Back to Editor</Button>
        </div>
      </div>

      <div class="w-[420px] flex flex-col shrink-0">
        <div class="p-4 border-b border-border flex flex-col gap-4 shrink-0 overflow-auto max-h-[50vh]">
          <span class="text-sm font-medium">AI Course Creator</span>
          <div class="flex flex-col gap-2">
            <label class="text-xs text-muted-foreground">Sources</label>
            <div v-for="(_, sourceIndex) in aiSources" :key="sourceIndex" class="flex gap-2">
              <Input v-model="aiSources[sourceIndex]" placeholder="Book, URL, or topic..." class="flex-1 h-9" />
              <Button v-if="aiSources.length > 1" variant="ghost" size="icon" class="shrink-0 h-8 w-8 hover:bg-destructive/10 hover:text-destructive" @click="handleRemoveSource(sourceIndex)"><X class="h-3.5 w-3.5" /></Button>
            </div>
            <Button variant="outline" class="w-full" @click="handleAddSource"><PlusCircle class="h-4 w-4" /></Button>
          </div>
          <div class="flex gap-3">
            <div class="flex flex-col gap-1.5 flex-1">
              <label class="text-xs text-muted-foreground">Segments</label>
              <Input v-model.number="aiSegmentCount" type="number" min="1" max="10" class="h-9" />
            </div>
            <div class="flex flex-col gap-1.5 flex-1">
              <label class="text-xs text-muted-foreground">Lessons/seg</label>
              <Input v-model.number="aiLessonsPerSegment" type="number" min="1" max="20" class="h-9" />
            </div>
            <div class="flex flex-col gap-1.5 flex-1">
              <label class="text-xs text-muted-foreground">Tone</label>
              <Input v-model="aiTone" class="h-9" />
            </div>
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="text-xs text-muted-foreground">System Prompt</label>
            <Textarea v-model="aiSystemPrompt" placeholder="You are an expert course designer..." class="min-h-[60px] text-xs" />
          </div>
        </div>
        <div class="flex-1 overflow-auto p-4 flex flex-col gap-3">
          <div v-if="aiChatMessages.length === 0" class="flex-1 flex items-center justify-center text-muted-foreground text-sm text-center px-8">Describe what to generate.</div>
          <div v-for="(message, messageIndex) in aiChatMessages" :key="messageIndex" class="flex flex-col gap-1">
            <span class="text-[10px] uppercase tracking-wider text-muted-foreground">{{ message.role }}</span>
            <div class="text-sm rounded-lg px-3 py-2" :class="message.role === 'user' ? 'bg-primary/10' : 'bg-muted'">{{ message.text }}</div>
          </div>
        </div>
        <div class="p-4 border-t border-border flex gap-2 shrink-0">
          <Input v-model="aiChatInput" placeholder="Describe the course..." class="flex-1 h-9" @keydown.enter="handleAISendMessage" />
          <Button class="h-9" @click="handleAISendMessage">Send</Button>
        </div>
      </div>
    </div>

    <!-- Main editor layout -->
    <div v-else class="flex flex-1 overflow-hidden">
      <!-- Left sidebar -->
      <aside class="w-72 border-r border-border flex flex-col shrink-0 overflow-hidden">
        <ScrollArea class="flex-1 h-0">
          <div class="p-5 flex flex-col gap-5">
            <!-- Segments -->
            <div v-if="hasActiveCourse" class="flex flex-col gap-2 bg-muted/40 rounded-lg p-3">
              <div class="flex items-center justify-between">
                <label class="text-xs text-muted-foreground uppercase tracking-wider flex items-center gap-1.5">
                  <span v-if="activePanel === 'segments'" class="w-1.5 h-1.5 rounded-full bg-primary shrink-0" />
                  Segments
                </label>

                <div class="flex items-center gap-0.5">
                  <!-- Segment move controls -->
                  <template v-if="hasActiveSegment">
                    <Button variant="ghost" size="icon" class="h-8 w-8" @click="store.moveSegmentUp()"><ChevronUp class="h-4 w-4" /></Button>
                    <Button variant="ghost" size="icon" class="h-8 w-8" @click="store.moveSegmentDown()"><ChevronDown class="h-4 w-4" /></Button>

                  </template>

                  <Button variant="ghost" size="icon" class="h-8 w-8" @click="store.addSegment()"><PlusCircle class="h-4 w-4" /></Button>
                </div>
              </div>

              <TransitionGroup tag="div" name="nav-list" class="flex flex-col gap-0.5">
              <div
                v-for="(segment, segmentIndex) in store.activeCourse!.segments"
                :key="segment['segment-id']"
                class="text-sm px-4 py-3 rounded-lg cursor-pointer transition-colors flex items-center gap-2 group/seg"
                :class="getNavItemClass(isSegmentSelected(segmentIndex))"
                :style="getNavItemStyle(isSegmentSelected(segmentIndex))"
                @click="(e: MouseEvent) => { if (e.shiftKey) { openSegmentSettingsIndex = segmentIndex } else { store.selectSegment(segmentIndex); activePanel = 'segments' } }"
                @contextmenu.prevent="openSegmentSettingsIndex = segmentIndex"
              >
                <span class="flex-1 truncate select-none">{{ segment['segment-title'] }}</span>

                <!-- Segment settings popover (shift+click) -->
                <Popover :open="openSegmentSettingsIndex === segmentIndex" @update:open="(val: boolean) => { if (!val) openSegmentSettingsIndex = null }">
                  <PopoverTrigger as-child><span /></PopoverTrigger>
                  <PopoverContent side="right" :side-offset="8" class="w-64">
                    <div class="flex flex-col gap-3">
                      <div class="flex flex-col gap-1.5">
                        <label class="text-xs text-muted-foreground">Title</label>
                        <Input v-model="segment['segment-title']" class="h-8 text-sm" />
                      </div>

                      <div class="flex flex-col gap-1.5">
                        <label class="text-xs text-muted-foreground">Symbol</label>
                        <Input v-model="segment['segment-symbol']" class="h-8 text-sm" />
                      </div>

                      <AlertDialog>
                        <AlertDialogTrigger as-child>
                          <Button variant="outline" size="sm" class="w-full hover:bg-destructive/10 hover:text-destructive hover:border-destructive/30">
                            <Trash2 class="h-3.5 w-3.5" />
                            Delete Segment
                          </Button>
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                          <AlertDialogHeader>
                            <AlertDialogTitle>Delete segment?</AlertDialogTitle>
                            <AlertDialogDescription>This will delete "{{ segment['segment-title'] }}" and all its packages.</AlertDialogDescription>
                          </AlertDialogHeader>
                          <AlertDialogFooter>
                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                            <AlertDialogAction class="bg-destructive text-destructive-foreground hover:bg-destructive/90" @click="store.removeSegment(segmentIndex); openSegmentSettingsIndex = null">Delete</AlertDialogAction>
                          </AlertDialogFooter>
                        </AlertDialogContent>
                      </AlertDialog>
                    </div>
                  </PopoverContent>
                </Popover>
              </div>
              </TransitionGroup>
            </div>

            <Separator v-if="hasActiveSegment" />

            <!-- Packages -->
            <div v-if="hasActiveSegment" class="flex flex-col gap-2" :class="store.activeSegment!.lessons.length > 0 ? 'bg-muted/40 rounded-lg p-3' : ''"
>
              <div class="flex items-center justify-between">
                <label class="text-xs text-muted-foreground uppercase tracking-wider flex items-center gap-1.5">

                  Packages
                  <span
                    class="text-[10px] normal-case tracking-normal px-1.5 py-0.5 rounded-full"
                    :class="activePanel === 'packages' ? 'bg-foreground text-background' : ''"
                  >{{ store.activePackageIndex + 1 }}/{{ store.activeSegment!.lessons.length }}</span>
                </label>

                <div class="flex items-center gap-0.5">

                  <Button v-if="hasActivePackage" variant="ghost" size="icon" class="h-8 w-8" @click="store.movePackageUp()"><ChevronUp class="h-4 w-4" /></Button>
                  <Button v-if="hasActivePackage" variant="ghost" size="icon" class="h-8 w-8" @click="store.movePackageDown()"><ChevronDown class="h-4 w-4" /></Button>
                  <Button variant="ghost" size="icon" class="h-8 w-8" @click="store.addPackage()"><PlusCircle class="h-4 w-4" /></Button>
                </div>
              </div>

              <TransitionGroup :key="store.activeSegmentIndex" tag="div" name="nav-list" class="flex flex-col gap-0.5">
              <div
                v-for="(pkg, packageIndex) in store.activeSegment!.lessons"
                :key="pkg['lesson-id']"
                :data-package-index="packageIndex"
                class="text-sm px-4 py-3 rounded-lg cursor-pointer transition-colors flex items-center gap-2 group/pkg"
                :class="getNavItemClass(isPackageSelected(packageIndex))"
                :style="getNavItemStyle(isPackageSelected(packageIndex))"
                @click="(e: MouseEvent) => { if (e.shiftKey) { openPackageSettingsIndex = packageIndex } else { store.selectPackage(packageIndex); activePanel = 'swipes' } }"
                @contextmenu.prevent="openPackageSettingsIndex = packageIndex"
              >
                <span class="flex-1 truncate select-none">{{ pkg.title }}</span>

                <!-- Package settings popover (shift+click) -->
                <Popover :open="openPackageSettingsIndex === packageIndex" @update:open="(val: boolean) => { if (!val) openPackageSettingsIndex = null }">
                  <PopoverTrigger as-child><span /></PopoverTrigger>
                  <PopoverContent side="right" :side-offset="8" class="w-64">
                    <div class="flex flex-col gap-3">
                      <div class="flex flex-col gap-1.5">
                        <label class="text-xs text-muted-foreground">Title</label>
                        <Input v-model="pkg.title" class="h-8 text-sm" />
                      </div>

                      <div class="flex items-center gap-2">
                        <Checkbox :checked="pkg.isFree" @update:checked="(val: boolean) => pkg.isFree = val" />
                        <label class="text-xs text-muted-foreground">Free</label>
                      </div>

                      <AlertDialog>
                        <AlertDialogTrigger as-child>
                          <Button variant="outline" size="sm" class="w-full mt-2 hover:bg-destructive/10 hover:text-destructive hover:border-destructive/30">
                            <Trash2 class="h-3.5 w-3.5" />
                            Delete Package
                          </Button>
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                          <AlertDialogHeader>
                            <AlertDialogTitle>Delete package?</AlertDialogTitle>
                            <AlertDialogDescription>This will delete "{{ pkg.title }}" and all its swipes.</AlertDialogDescription>
                          </AlertDialogHeader>
                          <AlertDialogFooter>
                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                            <AlertDialogAction class="bg-destructive text-destructive-foreground hover:bg-destructive/90" @click="store.removePackage(packageIndex); openPackageSettingsIndex = null">Delete</AlertDialogAction>
                          </AlertDialogFooter>
                        </AlertDialogContent>
                      </AlertDialog>
                    </div>
                  </PopoverContent>
                </Popover>
              </div>
              </TransitionGroup>
            </div>
          </div>
        </ScrollArea>
      </aside>

      <!-- Center -->
      <main class="flex-1 flex flex-col overflow-hidden">
        <div v-if="!hasActivePackage" class="flex-1 flex items-center justify-center text-muted-foreground">
          Select a package to start editing
        </div>

        <div v-else class="flex-1 flex overflow-hidden">
          <!-- Swipe list panel -->
          <div class="w-48 border-r border-border flex flex-col shrink-0 overflow-hidden">
            <!-- Add controls -->
            <div class="border-b border-border px-2 py-1.5 flex items-center gap-1">
              <!-- Quick add -->
              <Button
                v-for="quickType in QUICK_ADD_TYPES"
                :key="quickType"
                variant="ghost"
                size="icon"
                class="h-8 w-8"
                @click="handleAddSwipe(quickType)"
              >
                <span class="text-sm" :style="{ color: ENTITY_TYPE_COLORS[quickType] }">{{ ENTITY_TYPE_ICONS[quickType] }}</span>
              </Button>

              <span class="flex-1" />

              <!-- Add dialog -->
              <Dialog v-model:open="showAddSwipeDialog">
                <DialogTrigger as-child>
                  <Button variant="ghost" size="icon" class="h-8 w-8"><PlusCircle class="h-4 w-4" /></Button>
                </DialogTrigger>
                <DialogContent class="max-w-md">
                  <DialogHeader><DialogTitle>Add Swipe</DialogTitle></DialogHeader>
                  <div class="flex flex-col gap-4 pt-2">
                    <div v-for="group in ENTITY_TYPE_GROUPS" :key="group.label" class="flex flex-col gap-2">
                      <label class="text-xs text-muted-foreground uppercase tracking-wider">{{ group.label }}</label>
                      <div class="grid grid-cols-3 gap-2">
                        <button
                          v-for="entityType in group.types"
                          :key="entityType"
                          class="flex flex-col items-center justify-center gap-1.5 p-3 rounded-lg border hover:bg-accent transition-colors cursor-pointer text-center"
                          :style="{ borderColor: ENTITY_TYPE_COLORS[entityType] + '40' }"
                          @click="handleAddSwipe(entityType)"
                        >
                          <span class="text-lg" :style="{ color: ENTITY_TYPE_COLORS[entityType] }">{{ ENTITY_TYPE_ICONS[entityType] }}</span>
                          <span class="text-xs font-medium">{{ ENTITY_TYPE_LABELS[entityType] }}</span>
                        </button>
                      </div>
                    </div>
                  </div>
                </DialogContent>
              </Dialog>
            </div>

            <!-- Ordering controls -->
            <div v-if="hasActiveSwipe" class="border-b border-border px-2 py-1.5 flex items-center gap-1">
              <Button variant="ghost" size="icon" class="h-8 w-8" @click="handleMoveSwipeUp"><ChevronUp class="h-4 w-4" /></Button>
              <Button variant="ghost" size="icon" class="h-8 w-8" @click="handleMoveSwipeDown"><ChevronDown class="h-4 w-4" /></Button>
              <span class="flex-1 flex justify-end">
                <span
                  class="text-[10px] px-1.5 py-0.5 rounded-full"
                  :class="activePanel === 'swipes' ? 'bg-foreground text-background' : 'text-muted-foreground'"
                >{{ (store.activeSwipeIndex ?? 0) + 1 }}/{{ store.activePackage?.content.length }}</span>
              </span>

              <Button v-if="store.lastDeletedSwipe" variant="ghost" size="icon" class="h-8 w-8" @click="store.undoDeleteSwipe()">
                <Undo2 class="h-3.5 w-3.5" />
              </Button>
            </div>

            <!-- Swipe list -->
            <ScrollArea class="flex-1 h-0">
              <TransitionGroup :key="`${store.activeSegmentIndex}-${store.activePackageIndex}`" tag="div" name="swipe-list" class="p-1.5 flex flex-col gap-1.5">
                <div
                  v-for="(swipe, swipeIndex) in store.activePackage!.content"
                  :key="(swipe as any)._uid"
                  :data-swipe-index="swipeIndex"
                  class="px-4 py-3 rounded-lg flex items-center gap-2 group transition-colors cursor-pointer"
                  :class="[getSwipeItemClass(isSwipeSelected(swipeIndex))]"
                  :style="getSwipeItemStyle(swipe, isSwipeSelected(swipeIndex))"
                  @click="store.selectSwipe(swipeIndex); activePanel = 'swipes'"
                >
                  <!-- Icon -->
                  <span
                    class="shrink-0 text-sm"
                    :style="{ color: ENTITY_TYPE_COLORS[(swipe as any)['entity-type'] as EntityType] }"
                  >
                    {{ ENTITY_TYPE_ICONS[(swipe as any)['entity-type'] as EntityType] }}
                  </span>

                  <!-- Label -->
                  <span class="flex-1 truncate text-sm">
                    {{ ENTITY_TYPE_LABELS[(swipe as any)['entity-type'] as EntityType] }}
                  </span>

                  <!-- Remove -->
                  <Button
                    variant="ghost"
                    size="icon"
                    class="shrink-0 h-6 w-6 opacity-0 group-hover:opacity-100 transition-opacity hover:bg-destructive/10 hover:text-destructive"
                    @click.stop="store.removeSwipe(swipeIndex)"
                  >
                    <X class="h-3 w-3" />
                  </Button>
                </div>
              </TransitionGroup>
            </ScrollArea>

          </div>

          <!-- Swipe editor -->
          <div class="flex-1 overflow-auto bg-muted/40">
            <div v-if="hasActiveSwipe" class="p-8">
              <ContentBlockEditor :key="store.activeSwipeIndex ?? -1" :block="store.activeSwipe!" />
            </div>
            <div v-else class="flex-1 flex items-center justify-center h-full text-muted-foreground text-sm">
              Select a swipe to edit
            </div>
          </div>
        </div>
      </main>

      <!-- Right: preview + JSON toggle -->
      <aside class="w-[380px] border-l border-border flex flex-col shrink-0">
        <div class="flex-1 flex items-center justify-center p-6 bg-muted/30">
          <PhonePreview />
        </div>
        <div class="p-3 border-t border-border">
          <Button variant="outline" size="sm" class="w-full text-xs gap-2" @click="toggleJsonView"><Code class="h-3 w-3" /> JSON</Button>
        </div>
      </aside>
    </div>
  </div>
</template>
