<script setup lang="ts">
// Rich text editor for a single text segment
// Supports coloring text with Readlock markup: <c:r>red</c:r> <c:g>green</c:g>

import { ref, watch, onBeforeUnmount } from 'vue'
import { useEditor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import { TextStyle } from '@tiptap/extension-text-style'
import { Color } from '@tiptap/extension-color'
import { Button } from '@/components/ui/button'

const props = defineProps<{ modelValue: string }>()
const emit = defineEmits<{ (e: 'update:modelValue', value: string): void }>()

// * Convert Readlock markup to HTML for the editor

function markupToHtml(text: string): string {
  return text
    .replace(/<c:r>(.*?)<\/c:r>/g, '<span style="color: #dc2626">$1</span>')
    .replace(/<c:g>(.*?)<\/c:g>/g, '<span style="color: #16a34a">$1</span>')
}

// * Convert editor HTML back to Readlock markup

function htmlToMarkup(html: string): string {
  let result = html
    .replace(/<p>/g, '')
    .replace(/<\/p>/g, '')
    .replace(/<br\s*\/?>/g, '')

  result = result.replace(/<span style="color: #dc2626">(.*?)<\/span>/g, '<c:r>$1</c:r>')
  result = result.replace(/<span style="color: #16a34a">(.*?)<\/span>/g, '<c:g>$1</c:g>')

  // Strip any remaining HTML tags
  result = result.replace(/<[^>]*>/g, '')

  return result
}

// * Selection state for floating toolbar

const hasSelection = ref(false)
const toolbarTop = ref(0)
const toolbarLeft = ref(0)
const editorContainer = ref<HTMLElement | null>(null)

function updateSelectionState() {
  const editorInstance = editor.value
  const hasNoEditor = !editorInstance

  if (hasNoEditor) {
    hasSelection.value = false
    return
  }

  const { from, to } = editorInstance!.state.selection
  const isTextSelected = from !== to

  if (isTextSelected && editorContainer.value) {
    const domSelection = window.getSelection()
    const hasRange = domSelection && domSelection.rangeCount > 0

    if (hasRange) {
      const range = domSelection!.getRangeAt(0)
      const rect = range.getBoundingClientRect()
      const containerRect = editorContainer.value.getBoundingClientRect()

      toolbarTop.value = rect.top - containerRect.top - 40
      toolbarLeft.value = rect.left - containerRect.left + rect.width / 2
    }
  }

  hasSelection.value = isTextSelected
}

// * Editor instance

const editor = useEditor({
  content: markupToHtml(props.modelValue),
  extensions: [
    StarterKit.configure({
      heading: false,
      bulletList: false,
      orderedList: false,
      blockquote: false,
      codeBlock: false,
      horizontalRule: false,
    }),
    TextStyle,
    Color,
  ],
  editorProps: {
    attributes: {
      class: 'min-h-[48px] px-3 py-2 text-sm outline-none cursor-text',
    },
  },
  onUpdate({ editor: ed }) {
    const markup = htmlToMarkup(ed.getHTML())

    emit('update:modelValue', markup)
  },
  onSelectionUpdate() {
    updateSelectionState()
  },
  onBlur() {
    setTimeout(() => {
      hasSelection.value = false
    }, 200)
  },
})

// * Sync external changes

watch(() => props.modelValue, (newVal) => {
  const editorInstance = editor.value
  const hasNoEditor = !editorInstance

  if (hasNoEditor) {
    return
  }

  const currentMarkup = htmlToMarkup(editorInstance!.getHTML())
  const isAlreadySynced = currentMarkup === newVal

  if (isAlreadySynced) {
    return
  }

  editorInstance!.commands.setContent(markupToHtml(newVal))
})

onBeforeUnmount(() => {
  editor.value?.destroy()
})

// * Color actions

function applyRed() {
  editor.value?.chain().focus().setColor('#dc2626').run()
}

function applyGreen() {
  editor.value?.chain().focus().setColor('#16a34a').run()
}

function clearColor() {
  editor.value?.chain().focus().unsetColor().run()
}
</script>

<template>
  <div ref="editorContainer" class="rounded-md border border-input bg-transparent overflow-visible focus-within:border-ring transition-colors relative">
    <!-- Floating toolbar on selection -->
    <div
      v-if="hasSelection"
      class="absolute z-50 flex items-center gap-0.5 rounded-lg border border-border bg-popover p-1 shadow-md"
      :style="{ top: toolbarTop + 'px', left: toolbarLeft + 'px', transform: 'translateX(-50%)' }"
    >
      <Button variant="ghost" size="icon" class="h-7 w-7 text-red-500 text-xs font-bold" @mousedown.prevent="applyRed">
        W
      </Button>

      <Button variant="ghost" size="icon" class="h-7 w-7 text-green-500 text-xs font-bold" @mousedown.prevent="applyGreen">
        G
      </Button>

      <Button variant="ghost" size="icon" class="h-7 w-7 text-muted-foreground text-xs" @mousedown.prevent="clearColor">
        A
      </Button>
    </div>

    <!-- Editor -->
    <div class="cursor-text" @click="editor?.commands.focus()">
      <EditorContent :editor="editor" />
    </div>
  </div>
</template>
