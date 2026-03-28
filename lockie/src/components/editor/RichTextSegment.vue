<script setup lang="ts">
// Rich text editor for a single text segment
// Supports coloring text with Readlock markup: <c:r>red</c:r> <c:g>green</c:g>

import { watch, onBeforeUnmount } from 'vue'
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
  <div class="rounded-md border border-input bg-transparent overflow-hidden flex">
    <!-- Editor -->
    <div class="flex-1">
      <EditorContent :editor="editor" />
    </div>

    <!-- Toolbar -->
    <div class="flex flex-col items-center gap-1 px-1 py-1 border-l border-border bg-muted/30">
      <Button variant="ghost" size="icon" class="h-6 w-6 text-red-500 text-xs font-bold" @click="applyRed">
        W
      </Button>

      <Button variant="ghost" size="icon" class="h-6 w-6 text-green-500 text-xs font-bold" @click="applyGreen">
        G
      </Button>

      <Button variant="ghost" size="icon" class="h-6 w-6 text-muted-foreground text-xs" @click="clearColor">
        A
      </Button>
    </div>
  </div>
</template>
