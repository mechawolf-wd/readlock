// Composable for SortableJS drag-and-drop on a list
// Usage: useSortable(containerRef, list, onReorder)

import { onMounted, onUnmounted, watch, type Ref } from 'vue'
import Sortable from 'sortablejs'

export function useSortable(
  containerRef: Ref<HTMLElement | null>,
  list: Ref<unknown[]>,
  onReorder?: () => void,
) {
  let sortableInstance: Sortable | null = null

  function initSortable() {
    destroySortable()

    const container = containerRef.value

    if (!container) {
      return
    }

    sortableInstance = Sortable.create(container, {
      handle: '.drag-handle',
      animation: 150,
      ghostClass: 'sortable-ghost',
      chosenClass: '',
      dragClass: 'opacity-40',
      onEnd(event) {
        const oldIndex = event.oldIndex
        const newIndex = event.newIndex

        const hasValidIndices = oldIndex !== undefined && newIndex !== undefined
        const isSamePosition = oldIndex === newIndex

        if (!hasValidIndices || isSamePosition) {
          return
        }

        // Revert the DOM change SortableJS made, so Vue handles all DOM updates
        const parent = event.from
        const movedNode = event.item

        parent.removeChild(movedNode)

        const referenceNode = parent.children[oldIndex]

        if (referenceNode) {
          parent.insertBefore(movedNode, referenceNode)
        } else {
          parent.appendChild(movedNode)
        }

        // Now update the reactive array — Vue will reconcile the DOM
        const moved = list.value.splice(oldIndex, 1)[0]

        if (moved) {
          list.value.splice(newIndex, 0, moved)
        }

        if (onReorder) {
          onReorder()
        }
      },
    })
  }

  function destroySortable() {
    if (sortableInstance) {
      sortableInstance.destroy()
      sortableInstance = null
    }
  }

  onMounted(initSortable)
  onUnmounted(destroySortable)

  // Re-init when container changes
  watch(containerRef, initSortable)
}
