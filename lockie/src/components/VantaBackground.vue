<script setup lang="ts">
// Animated 3D header background with a slowly spinning low-poly bird

import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import * as THREE from 'three'

const containerRef = ref<HTMLElement | null>(null)
let renderer: THREE.WebGLRenderer | null = null
let animationId: number | null = null

function createBirdGeometry(): THREE.BufferGeometry {
  const geometry = new THREE.BufferGeometry()

  // Low-poly origami bird — all triangles
  const vertices = new Float32Array([
    // Body (diamond shape — 4 triangles)
    0, 0, 0.8,     0.25, 0.05, 0,    0, 0.12, 0,    // Top-right body
    0, 0, 0.8,     0, 0.12, 0,      -0.25, 0.05, 0,  // Top-left body
    0, 0, 0.8,    -0.25, -0.05, 0,   0, -0.12, 0,    // Bottom-left body
    0, 0, 0.8,     0, -0.12, 0,      0.25, -0.05, 0,  // Bottom-right body

    // Body back (same but to tail)
    0, 0, -0.5,    0, 0.12, 0,       0.25, 0.05, 0,  // Top-right back
    0, 0, -0.5,   -0.25, 0.05, 0,    0, 0.12, 0,     // Top-left back
    0, 0, -0.5,    0, -0.12, 0,     -0.25, -0.05, 0,  // Bottom-left back
    0, 0, -0.5,    0.25, -0.05, 0,   0, -0.12, 0,     // Bottom-right back

    // Beak (pointed cone)
    0, 0, 0.8,     0.06, 0.02, 0.8,  0, 0.02, 1.1,   // Beak top
    0, 0, 0.8,     0, -0.02, 1.1,    0.06, -0.02, 0.8, // Beak bottom
    0, 0, 0.8,    -0.06, 0.02, 0.8,  0, 0.02, 1.1,   // Beak top left
    0, 0, 0.8,     0, -0.02, 1.1,   -0.06, -0.02, 0.8, // Beak bottom left

    // Tail (flared out)
    0, 0, -0.5,    0.15, 0.08, -0.9,  -0.15, 0.08, -0.9,  // Tail top
    0, 0, -0.5,   -0.15, -0.04, -0.85, 0.15, -0.04, -0.85, // Tail bottom

    // Right wing (3 triangles)
    0.25, 0.05, 0,    0.9, 0.15, -0.1,    0.25, 0.05, -0.3,  // Wing base
    0.25, 0.05, 0,    0.9, 0.15, -0.1,    0.25, 0.05, 0.2,   // Wing front
    0.9, 0.15, -0.1,  0.7, 0.12, -0.4,    0.25, 0.05, -0.3,  // Wing tip

    // Left wing (3 triangles, mirrored)
    -0.25, 0.05, 0,   -0.9, 0.15, -0.1,  -0.25, 0.05, -0.3,
    -0.25, 0.05, 0,   -0.9, 0.15, -0.1,  -0.25, 0.05, 0.2,
    -0.9, 0.15, -0.1, -0.7, 0.12, -0.4,  -0.25, 0.05, -0.3,
  ])

  geometry.setAttribute('position', new THREE.BufferAttribute(vertices, 3))
  geometry.computeVertexNormals()

  return geometry
}

function initScene() {
  const hasNoContainer = !containerRef.value

  if (hasNoContainer) {
    return
  }

  destroyScene()

  const container = containerRef.value!
  const width = container.clientWidth
  const height = container.clientHeight

  // Scene
  const scene = new THREE.Scene()
  scene.background = new THREE.Color(0x0a0a0a)

  // Camera
  const camera = new THREE.PerspectiveCamera(40, width / height, 0.1, 100)
  camera.position.set(1.8, 0.3, 0.8)
  camera.lookAt(0, 0, 0)

  // Lighting
  const ambientLight = new THREE.AmbientLight(0x333333)
  scene.add(ambientLight)

  const keyLight = new THREE.DirectionalLight(0xffffff, 1.2)
  keyLight.position.set(3, 4, 5)
  scene.add(keyLight)

  const rimLight = new THREE.DirectionalLight(0xff3333, 0.6)
  rimLight.position.set(-3, 1, -2)
  scene.add(rimLight)

  const fillLight = new THREE.DirectionalLight(0x662222, 0.4)
  fillLight.position.set(-2, -1, 3)
  scene.add(fillLight)

  // Bird
  const birdGeometry = createBirdGeometry()

  const birdMaterial = new THREE.MeshStandardMaterial({
    color: 0xcc2233,
    roughness: 0.4,
    metalness: 0.15,
    flatShading: true,
    side: THREE.DoubleSide,
  })

  const bird = new THREE.Mesh(birdGeometry, birdMaterial)
  scene.add(bird)

  // Renderer
  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false })
  renderer.setSize(width, height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  container.appendChild(renderer.domElement)

  // Animation loop
  function animate() {
    bird.rotation.y += 0.004

    // Gentle bob
    bird.position.y = Math.sin(Date.now() * 0.001) * 0.03

    renderer!.render(scene, camera)
    animationId = requestAnimationFrame(animate)
  }

  animate()

  // Handle resize
  const resizeObserver = new ResizeObserver(() => {
    const newWidth = container.clientWidth
    const newHeight = container.clientHeight

    camera.aspect = newWidth / newHeight
    camera.updateProjectionMatrix()
    renderer!.setSize(newWidth, newHeight)
  })

  resizeObserver.observe(container)
}

function destroyScene() {
  if (animationId) {
    cancelAnimationFrame(animationId)
    animationId = null
  }

  if (renderer) {
    renderer.dispose()
    renderer.domElement.remove()
    renderer = null
  }
}

onMounted(() => {
  nextTick(() => {
    initScene()
  })
})

onUnmounted(() => {
  destroyScene()
})
</script>

<template>
  <div ref="containerRef" class="absolute inset-0" />
</template>
