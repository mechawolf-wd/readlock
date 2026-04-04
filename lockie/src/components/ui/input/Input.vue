<script setup lang="ts">
import type { HTMLAttributes } from "vue"
import { computed } from "vue"
import { useVModel } from "@vueuse/core"
import { cn } from "@/lib/utils"

const props = withDefaults(defineProps<{
  defaultValue?: string | number
  modelValue?: string | number
  class?: HTMLAttributes["class"]
  variant?: "default" | "compact" | "subtle"
}>(), {
  variant: "default",
})

const emits = defineEmits<{
  (e: "update:modelValue", payload: string | number): void
}>()

const modelValue = useVModel(props, "modelValue", emits, {
  passive: true,
  defaultValue: props.defaultValue,
})

const baseClasses = 'file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 border-input w-full min-w-0 rounded-md border bg-transparent px-3 py-1 shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 focus-visible:border-ring focus-visible:ring-0 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive'

const variantClasses = computed(() => {
  if (props.variant === "compact") {
    return "h-8 text-sm"
  }

  if (props.variant === "subtle") {
    return "h-9 text-sm bg-muted/30 border-border italic text-muted-foreground"
  }

  return "h-9 text-base md:text-sm"
})
</script>

<template>
  <input
    v-model="modelValue"
    data-slot="input"
    :class="cn(baseClasses, variantClasses, props.class)"
  >
</template>
