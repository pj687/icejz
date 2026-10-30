<template>
	<div ref="wrapRef" class="ice-bot-3d" :class="[size, { interactive }]" :style="wrapStyle">
		<canvas ref="canvasRef" class="bot-canvas" @contextmenu.prevent />
		<div v-if="loading" class="loading-dot">加载小冰…</div>
		<div v-if="showHint" class="hint">拖拽微调角度 · Alt拖拽移动 · 点击互动</div>
	</div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import * as THREE from 'three'
import { createIceBotRig, type IceBotAction, type IceBotRig } from './iceBot3dFactory'

const props = withDefaults(
	defineProps<{
		size?: 'sm' | 'md' | 'lg' | 'xl'
		interactive?: boolean
		autoRotate?: boolean
		showHint?: boolean
		action?: IceBotAction | null
	}>(),
	{
		size: 'md',
		interactive: true,
		autoRotate: true,
		showHint: false,
		action: null
	}
)

const emit = defineEmits<{
	interact: [action: IceBotAction]
	click: []
}>()

const wrapRef = ref<HTMLElement | null>(null)
const canvasRef = ref<HTMLCanvasElement | null>(null)
const loading = ref(true)

const sizeMap = { sm: 72, md: 120, lg: 168, xl: 220 }
const wrapStyle = computed(() => {
	const s = sizeMap[props.size]
	return { width: `${s}px`, height: `${s}px` }
})

let renderer: THREE.WebGLRenderer | null = null
let scene: THREE.Scene | null = null
let camera: THREE.PerspectiveCamera | null = null
let rig: IceBotRig | null = null
let raf = 0
let disposed = false

const yaw = ref(0)
const pitch = ref(0)
let autoYaw = 0
let rotating = false
let pointerId = 0
let lastX = 0
let lastY = 0
let moved = false
const clock = new THREE.Clock()

const resize = () => {
	if (!wrapRef.value || !renderer || !camera) return
	const { clientWidth: w, clientHeight: h } = wrapRef.value
	renderer.setSize(w, h, false)
	camera.aspect = w / Math.max(h, 1)
	camera.updateProjectionMatrix()
}

const applyOrbit = () => {
	if (!rig) return
	rig.root.rotation.order = 'YXZ'
	rig.root.rotation.y = yaw.value + autoYaw
	rig.root.rotation.x = pitch.value
}

const play = (action: IceBotAction) => {
	rig?.setAction(action)
	emit('interact', action)
}

const onPointerDown = (e: PointerEvent) => {
	if (!props.interactive || e.button !== 0 || e.altKey) return
	const canvas = canvasRef.value
	if (!canvas) return
	rotating = true
	moved = false
	pointerId = e.pointerId
	canvas.setPointerCapture(pointerId)
	lastX = e.clientX
	lastY = e.clientY
}

const onPointerMove = (e: PointerEvent) => {
	if (!rotating) return
	const dx = e.clientX - lastX
	const dy = e.clientY - lastY
	if (Math.abs(dx) + Math.abs(dy) > 2) moved = true
	lastX = e.clientX
	lastY = e.clientY
	// 限制侧视角度，避免立绘挤出立牌露出难看的纯侧面
	yaw.value = Math.max(-0.38, Math.min(0.38, yaw.value + dx * 0.01))
	pitch.value = Math.max(-0.22, Math.min(0.18, pitch.value + dy * 0.005))
	applyOrbit()
}

const onPointerUp = () => {
	if (!rotating) return
	rotating = false
	try {
		canvasRef.value?.releasePointerCapture(pointerId)
	} catch {
		// ignore
	}
	if (!moved) {
		const actions: IceBotAction[] = ['wave', 'nod', 'jump', 'spin']
		play(actions[Math.floor(Math.random() * actions.length)])
		emit('click')
	}
}

const init = async () => {
	if (!canvasRef.value || !wrapRef.value) return
	disposed = false
	const w = wrapRef.value.clientWidth
	const h = wrapRef.value.clientHeight

	renderer = new THREE.WebGLRenderer({
		canvas: canvasRef.value,
		alpha: true,
		antialias: true,
		powerPreference: 'high-performance'
	})
	renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2))
	renderer.setSize(w, h, false)
	renderer.setClearColor(0x000000, 0)
	renderer.outputColorSpace = THREE.SRGBColorSpace
	renderer.toneMapping = THREE.ACESFilmicToneMapping
	renderer.toneMappingExposure = 1.05

	scene = new THREE.Scene()
	camera = new THREE.PerspectiveCamera(30, w / Math.max(h, 1), 0.1, 40)
	camera.position.set(0, 1.2, 4.4)
	camera.lookAt(0, 1.15, 0)

	scene.add(new THREE.HemisphereLight(0xffffff, 0xc9dde8, 0.95))
	const key = new THREE.DirectionalLight(0xffffff, 0.85)
	key.position.set(1.6, 3.2, 3.8)
	scene.add(key)
	const fill = new THREE.DirectionalLight(0xd5eef8, 0.4)
	fill.position.set(-2.2, 1.4, 1.8)
	scene.add(fill)

	const loader = new THREE.TextureLoader()
	const texture = await new Promise<THREE.Texture>((resolve, reject) => {
		loader.load('/mascot/xiaobing.png', resolve, undefined, reject)
	}).catch(() => {
		const c = document.createElement('canvas')
		c.width = c.height = 8
		return new THREE.CanvasTexture(c)
	})

	if (disposed) {
		texture.dispose()
		return
	}

	rig = createIceBotRig(texture)
	rig.root.scale.setScalar(1.05)
	scene.add(rig.root)
	applyOrbit()
	loading.value = false

	canvasRef.value.addEventListener('pointerdown', onPointerDown)
	window.addEventListener('pointermove', onPointerMove)
	window.addEventListener('pointerup', onPointerUp)
	window.addEventListener('resize', resize)

	const loop = () => {
		if (disposed || !renderer || !scene || !camera || !rig) return
		raf = requestAnimationFrame(loop)
		const dt = clock.getDelta()
		const elapsed = clock.elapsedTime
		if (props.autoRotate && !rotating) {
			// 轻微左右摆头，不转到正侧面
			autoYaw = Math.sin(elapsed * 0.42) * 0.16
		}
		applyOrbit()
		rig.update(dt, elapsed)
		renderer.render(scene, camera)
	}
	clock.start()
	loop()
}

watch(
	() => props.action,
	val => {
		if (val) play(val)
	}
)

onMounted(() => {
	init()
})

onBeforeUnmount(() => {
	disposed = true
	cancelAnimationFrame(raf)
	canvasRef.value?.removeEventListener('pointerdown', onPointerDown)
	window.removeEventListener('pointermove', onPointerMove)
	window.removeEventListener('pointerup', onPointerUp)
	window.removeEventListener('resize', resize)
	rig?.dispose()
	rig = null
	renderer?.dispose()
	renderer = null
	scene = null
	camera = null
})

defineExpose({ play })
</script>

<style scoped lang="scss">
.ice-bot-3d {
	position: relative;
	display: inline-block;
	touch-action: none;
	user-select: none;
}

.bot-canvas {
	width: 100%;
	height: 100%;
	display: block;
	background: transparent;
	cursor: grab;
}

.ice-bot-3d.interactive:active .bot-canvas {
	cursor: grabbing;
}

.loading-dot {
	position: absolute;
	inset: 0;
	display: grid;
	place-items: center;
	font-size: 12px;
	color: #7a8796;
	pointer-events: none;
}

.hint {
	position: absolute;
	left: 50%;
	bottom: -2px;
	transform: translate(-50%, 100%);
	margin-top: 6px;
	padding: 4px 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 650;
	color: #007eb8;
	background: rgba(255, 255, 255, 0.88);
	border: 1px solid rgba(0, 168, 232, 0.16);
	white-space: nowrap;
	pointer-events: none;
	opacity: 0;
	transition: opacity 0.18s ease;
}

.ice-bot-3d:hover .hint {
	opacity: 1;
}
</style>
