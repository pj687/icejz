<template>
	<div class="signature-container">
		<div class="panel-hint">
			<span class="hint-dot"></span>
			在画布上手写签名，完成后点击保存；可用于审批与文书场景
		</div>

		<div class="signature-layout">
			<div class="canvas-panel">
				<div class="toolbar">
					<div class="tool-row">
						<span class="tool-label">笔触点</span>
						<div class="tip-picker" role="radiogroup" aria-label="笔触点">
							<button
								v-for="tip in penTips"
								:key="tip.id"
								type="button"
								class="tip-option"
								:class="[tip.id, { active: penTip === tip.id }]"
								role="radio"
								:aria-checked="penTip === tip.id"
								:title="tip.desc"
								@click="setPenTip(tip.id)"
							>
								<span class="tip-preview" aria-hidden="true" v-html="tip.preview"></span>
								<span class="tip-meta">
									<strong>{{ tip.label }}</strong>
									<em>{{ tip.desc }}</em>
								</span>
							</button>
						</div>
					</div>

					<div class="tool-row compact">
						<div class="tool-group">
							<span class="tool-label">粗细</span>
							<button
								v-for="size in penSizes"
								:key="size"
								type="button"
								class="chip"
								:class="{ active: lineWidth === size }"
								@click="setPenSize(size)"
							>
								<span class="chip-dot" :style="{ width: size * 2 + 'px', height: size * 2 + 'px' }"></span>
								{{ size }}px
							</button>
						</div>
						<div class="tool-group">
							<span class="tool-label">颜色</span>
							<button
								v-for="color in penColors"
								:key="color"
								type="button"
								class="color-dot"
								:class="{ active: strokeColor === color }"
								:style="{ background: color }"
								@click="setPenColor(color)"
							></button>
						</div>
						<div class="tool-group">
							<span class="tool-label">光标</span>
							<button
								v-for="item in cursorStyles"
								:key="item.id"
								type="button"
								class="chip cursor-chip"
								:class="{ active: cursorStyle === item.id }"
								:title="item.desc"
								@click="cursorStyle = item.id"
							>
								<span class="cursor-preview" aria-hidden="true" v-html="item.preview"></span>
								{{ item.label }}
							</button>
						</div>
					</div>
				</div>

				<div class="canvas-wrapper" :class="{ drawing: isDrawing }">
					<div class="canvas-label">签名画布</div>
					<div v-show="showGuide" class="canvas-guide" aria-hidden="true">在此处书写你的姓名</div>
					<canvas
						ref="canvasRef"
						class="signature-canvas"
						:style="{ cursor: activeCursor }"
						@mousedown="startDrawing"
						@mousemove="draw"
						@mouseup="stopDrawing"
						@mouseleave="stopDrawing"
						@touchstart="handleTouchStart"
						@touchmove="handleTouchMove"
						@touchend="stopDrawing"
					></canvas>
				</div>

				<div class="signature-actions">
					<button type="button" class="btn ghost" @click="clearCanvas">清空画布</button>
					<button type="button" class="btn primary" @click="saveSignature">保存签名</button>
				</div>
			</div>

			<aside class="side-panel">
				<div class="preview-card">
					<div class="preview-head">
						<strong>当前签名</strong>
						<em>{{ savedSignature ? '已保存' : '尚未保存' }}</em>
					</div>
					<div class="preview-box">
						<img v-if="savedSignature" :src="savedSignature" alt="签名预览" />
						<div v-else class="preview-empty">
							<svg viewBox="0 0 64 64" aria-hidden="true">
								<path
									d="M12 44c8-10 16-16 24-18 6-1 12 1 16 6"
									fill="none"
									stroke="#9db4c6"
									stroke-width="3"
									stroke-linecap="round"
								/>
								<path d="M44 28l8-8" stroke="#9db4c6" stroke-width="3" stroke-linecap="round" />
							</svg>
							<span>保存后将在此预览</span>
						</div>
					</div>
				</div>

				<div class="tip-card">
					<strong>书写建议</strong>
					<ul>
						<li>建议横屏或使用手写板，效果更清晰</li>
						<li>笔画连贯、居中书写更易识别</li>
						<li>可切换圆笔 / 软笔 / 马克笔 / 毛笔笔触</li>
						<li>保存前可随时清空重新签名</li>
					</ul>
				</div>
			</aside>
		</div>
	</div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { uploadImg } from '@/api/sys/upload'
import { useUserSignatureApi } from '@/api/sys/user'
import { useUserStore } from '@/store/modules/user'
const userStore = useUserStore()

type PenTipId = 'round' | 'soft' | 'marker' | 'calligraphy'
type CursorStyleId = 'cross' | 'pen' | 'dot'

const cursorSvg = (svg: string) => `url("data:image/svg+xml,${encodeURIComponent(svg)}")`

const canvasRef = ref<HTMLCanvasElement | null>(null)
let ctx: CanvasRenderingContext2D | null = null
let lastX = 0
let lastY = 0
const isDrawing = ref(false)
const hasInk = ref(false)
const savedSignature = ref<string>('')
const lineWidth = ref(3)
const strokeColor = ref('#122033')
const penTip = ref<PenTipId>('round')
const cursorStyle = ref<CursorStyleId>('pen')
const penSizes = [2, 3, 5]
const penColors = ['#122033', '#00a8e8', '#334155', '#e11d48']
const cursorStyles: Array<{ id: CursorStyleId; label: string; desc: string; css: string; preview: string }> = [
	{
		id: 'cross',
		label: '十字',
		desc: '精准十字准星',
		css: 'crosshair',
		preview: `<svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path d="M10 2v16M2 10h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><circle cx="10" cy="10" r="2.2" fill="none" stroke="currentColor" stroke-width="1.4"/></svg>`
	},
	{
		id: 'pen',
		label: '钢笔',
		desc: '书写钢笔指针',
		css: `${cursorSvg(`<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32"><path fill="#122033" d="M6 28l1.8-7.2L22.5 6.1l5.4 5.4L12.2 27.2z"/><path fill="#00A8E8" d="M22.5 6.1l5.4 5.4 2.1-2.1-5.4-5.4z"/><path fill="#fff" d="M8.2 25.6l1.2-1.2 3.2 3.2-1.2 1.2z"/><circle cx="6.2" cy="27.8" r="1.6" fill="#00A8E8"/></svg>`)} 6 28, crosshair`,
		preview: `<svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path d="M4 17l1.2-4.6L14.2 3.4l2.4 2.4L7.8 14.6z" fill="currentColor"/><path d="M14.2 3.4l2.4 2.4.9-.9-2.4-2.4z" fill="#00A8E8"/><circle cx="4.2" cy="16.8" r=".9" fill="#00A8E8"/></svg>`
	},
	{
		id: 'dot',
		label: '圆点',
		desc: '圆点定位光标',
		css: `${cursorSvg(`<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 28 28"><circle cx="14" cy="14" r="7" fill="none" stroke="#00A8E8" stroke-width="2"/><circle cx="14" cy="14" r="2.2" fill="#122033"/><path d="M14 3v3M14 22v3M3 14h3M22 14h3" stroke="#122033" stroke-width="1.6" stroke-linecap="round"/></svg>`)} 14 14, crosshair`,
		preview: `<svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><circle cx="10" cy="10" r="5" fill="none" stroke="currentColor" stroke-width="1.6"/><circle cx="10" cy="10" r="1.8" fill="currentColor"/><path d="M10 2.5v2M10 15.5v2M2.5 10h2M15.5 10h2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>`
	}
]
const activeCursor = computed(() => cursorStyles.find(item => item.id === cursorStyle.value)?.css || 'crosshair')
const penTips: Array<{ id: PenTipId; label: string; desc: string; preview: string }> = [
	{
		id: 'round',
		label: '圆笔',
		desc: '顺滑签字笔',
		preview: `<svg viewBox="0 0 56 28" xmlns="http://www.w3.org/2000/svg"><path d="M6 18c8-10 16-12 24-8s14 10 20 8" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/></svg>`
	},
	{
		id: 'soft',
		label: '软笔',
		desc: '柔和水彩感',
		preview: `<svg viewBox="0 0 56 28" xmlns="http://www.w3.org/2000/svg"><path d="M6 18c8-10 16-12 24-8s14 10 20 8" fill="none" stroke="currentColor" stroke-width="6" stroke-linecap="round" opacity=".28"/><path d="M6 18c8-10 16-12 24-8s14 10 20 8" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="round" opacity=".55"/></svg>`
	},
	{
		id: 'marker',
		label: '马克笔',
		desc: '方头马克笔',
		preview: `<svg viewBox="0 0 56 28" xmlns="http://www.w3.org/2000/svg"><path d="M6 18c8-10 16-12 24-8s14 10 20 8" fill="none" stroke="currentColor" stroke-width="5" stroke-linecap="square" stroke-linejoin="miter" opacity=".85"/></svg>`
	},
	{
		id: 'calligraphy',
		label: '毛笔',
		desc: '书法笔锋',
		preview: `<svg viewBox="0 0 56 28" xmlns="http://www.w3.org/2000/svg"><g fill="currentColor"><ellipse cx="10" cy="17" rx="5.2" ry="1.7" transform="rotate(-28 10 17)"/><ellipse cx="18" cy="12.5" rx="5.6" ry="1.7" transform="rotate(-18 18 12.5)"/><ellipse cx="28" cy="10.5" rx="5.8" ry="1.7" transform="rotate(-6 28 10.5)"/><ellipse cx="38" cy="12" rx="5.5" ry="1.7" transform="rotate(12 38 12)"/><ellipse cx="47" cy="16" rx="5" ry="1.7" transform="rotate(26 47 16)"/></g></svg>`
	}
]
const showGuide = computed(() => !isDrawing.value && !hasInk.value && !savedSignature.value)

onMounted(() => {
	initCanvas()
	loadSavedSignature()
	window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
	window.removeEventListener('resize', handleResize)
})

watch(
	() => userStore.user?.signature,
	newSignature => {
		if (newSignature && newSignature !== savedSignature.value) {
			savedSignature.value = newSignature
			setTimeout(() => {
				loadSignatureToCanvas(newSignature)
			}, 100)
		}
	}
)

const applyPenStyle = () => {
	if (!ctx) return
	ctx.globalAlpha = 1
	ctx.globalCompositeOperation = 'source-over'
	ctx.strokeStyle = strokeColor.value
	ctx.fillStyle = strokeColor.value
	ctx.lineWidth = lineWidth.value

	if (penTip.value === 'marker') {
		ctx.lineCap = 'square'
		ctx.lineJoin = 'miter'
	} else {
		ctx.lineCap = 'round'
		ctx.lineJoin = 'round'
	}
}

const setPenTip = (tip: PenTipId) => {
	penTip.value = tip
	applyPenStyle()
}

const setPenSize = (size: number) => {
	lineWidth.value = size
	applyPenStyle()
}

const setPenColor = (color: string) => {
	strokeColor.value = color
	applyPenStyle()
}

const stampDot = (x: number, y: number) => {
	if (!ctx) return
	const tip = penTip.value
	const size = lineWidth.value

	if (tip === 'soft') {
		ctx.globalAlpha = 0.35
		ctx.fillStyle = strokeColor.value
		ctx.beginPath()
		ctx.arc(x, y, size * 0.9, 0, Math.PI * 2)
		ctx.fill()
		ctx.globalAlpha = 1
		return
	}

	if (tip === 'calligraphy') {
		ctx.globalAlpha = 0.95
		ctx.fillStyle = strokeColor.value
		ctx.save()
		ctx.translate(x, y)
		ctx.rotate(-Math.PI / 5)
		ctx.beginPath()
		ctx.ellipse(0, 0, size * 1.35, size * 0.38, 0, 0, Math.PI * 2)
		ctx.fill()
		ctx.restore()
		ctx.globalAlpha = 1
		return
	}

	if (tip === 'marker') {
		ctx.globalAlpha = 0.88
		ctx.fillStyle = strokeColor.value
		const s = size * 1.35
		ctx.fillRect(x - s / 2, y - s / 2, s, s)
		ctx.globalAlpha = 1
		return
	}

	ctx.globalAlpha = 1
	ctx.fillStyle = strokeColor.value
	ctx.beginPath()
	ctx.arc(x, y, size / 2, 0, Math.PI * 2)
	ctx.fill()
}

const strokeTo = (x: number, y: number) => {
	if (!ctx) return

	const tip = penTip.value
	const dx = x - lastX
	const dy = y - lastY
	const dist = Math.hypot(dx, dy) || 0.001
	const angle = Math.atan2(dy, dx)
	const size = lineWidth.value

	if (tip === 'soft') {
		const width = Math.max(size * 0.7, Math.min(size * 2.4, size * 2 - dist * 0.12))
		const steps = Math.max(1, Math.ceil(dist / 1.8))
		ctx.fillStyle = strokeColor.value
		for (let i = 1; i <= steps; i++) {
			const t = i / steps
			const px = lastX + dx * t
			const py = lastY + dy * t
			ctx.globalAlpha = 0.22
			ctx.beginPath()
			ctx.arc(px, py, width / 2, 0, Math.PI * 2)
			ctx.fill()
			ctx.globalAlpha = 0.18
			ctx.beginPath()
			ctx.arc(px, py, width * 0.72, 0, Math.PI * 2)
			ctx.fill()
		}
		ctx.globalAlpha = 1
	} else if (tip === 'marker') {
		ctx.globalAlpha = 0.82
		ctx.lineCap = 'square'
		ctx.lineJoin = 'miter'
		ctx.lineWidth = size * 1.55
		ctx.strokeStyle = strokeColor.value
		ctx.beginPath()
		ctx.moveTo(lastX, lastY)
		ctx.lineTo(x, y)
		ctx.stroke()
		ctx.globalAlpha = 1
	} else if (tip === 'calligraphy') {
		const w = size * 2.15
		const h = size * 0.48
		const steps = Math.max(1, Math.ceil(dist / 1.2))
		ctx.fillStyle = strokeColor.value
		ctx.globalAlpha = 0.94
		for (let i = 1; i <= steps; i++) {
			const t = i / steps
			const px = lastX + dx * t
			const py = lastY + dy * t
			ctx.save()
			ctx.translate(px, py)
			ctx.rotate(angle + Math.PI / 5)
			ctx.beginPath()
			ctx.ellipse(0, 0, w / 2, h / 2, 0, 0, Math.PI * 2)
			ctx.fill()
			ctx.restore()
		}
		ctx.globalAlpha = 1
	} else {
		ctx.globalAlpha = 1
		ctx.lineCap = 'round'
		ctx.lineJoin = 'round'
		ctx.lineWidth = size
		ctx.strokeStyle = strokeColor.value
		ctx.beginPath()
		ctx.moveTo(lastX, lastY)
		ctx.lineTo(x, y)
		ctx.stroke()
	}

	lastX = x
	lastY = y
	hasInk.value = true
}

const initCanvas = () => {
	if (!canvasRef.value) {
		return
	}

	const canvas = canvasRef.value
	const container = canvas.parentElement

	if (container) {
		canvas.width = container.clientWidth - 4
		canvas.height = 360
	}

	ctx = canvas.getContext('2d')
	if (ctx) {
		applyPenStyle()
		ctx.clearRect(0, 0, canvas.width, canvas.height)
	}
}

const handleResize = () => {
	if (!canvasRef.value || !ctx) {
		return
	}
	const imageData = canvasRef.value.toDataURL()

	initCanvas()

	const img = new Image()
	img.onload = () => {
		if (ctx && canvasRef.value) {
			ctx.drawImage(img, 0, 0)
			applyPenStyle()
		}
	}
	img.src = imageData
}

const startDrawing = (e: MouseEvent) => {
	if (!ctx || !canvasRef.value) {
		return
	}
	isDrawing.value = true

	const rect = canvasRef.value.getBoundingClientRect()
	lastX = e.clientX - rect.left
	lastY = e.clientY - rect.top
	stampDot(lastX, lastY)
	hasInk.value = true
}

const draw = (e: MouseEvent) => {
	if (!isDrawing.value || !ctx || !canvasRef.value) {
		return
	}

	const rect = canvasRef.value.getBoundingClientRect()
	strokeTo(e.clientX - rect.left, e.clientY - rect.top)
}

const stopDrawing = () => {
	if (ctx) {
		ctx.globalAlpha = 1
	}
	isDrawing.value = false
}

const handleTouchStart = (e: TouchEvent) => {
	e.preventDefault()
	if (!ctx || !canvasRef.value) {
		return
	}
	isDrawing.value = true

	const rect = canvasRef.value.getBoundingClientRect()
	const touch = e.touches[0]
	lastX = touch.clientX - rect.left
	lastY = touch.clientY - rect.top
	stampDot(lastX, lastY)
	hasInk.value = true
}

const handleTouchMove = (e: TouchEvent) => {
	e.preventDefault()
	if (!isDrawing.value || !ctx || !canvasRef.value) {
		return
	}

	const rect = canvasRef.value.getBoundingClientRect()
	const touch = e.touches[0]
	strokeTo(touch.clientX - rect.left, touch.clientY - rect.top)
}

const clearCanvas = () => {
	if (!ctx || !canvasRef.value) {
		return
	}

	ctx.clearRect(0, 0, canvasRef.value.width, canvasRef.value.height)
	applyPenStyle()
	hasInk.value = false
	ElMessage.success('画布已清空')
}

const exportSignatureDataURL = () => {
	if (!canvasRef.value) {
		return ''
	}
	const source = canvasRef.value
	const exportCanvas = document.createElement('canvas')
	exportCanvas.width = source.width
	exportCanvas.height = source.height
	const exportCtx = exportCanvas.getContext('2d')
	if (!exportCtx) {
		return source.toDataURL('image/png')
	}
	exportCtx.fillStyle = '#ffffff'
	exportCtx.fillRect(0, 0, exportCanvas.width, exportCanvas.height)
	exportCtx.drawImage(source, 0, 0)
	return exportCanvas.toDataURL('image/png')
}

const saveSignature = async () => {
	if (!canvasRef.value) {
		return
	}
	if (!hasInk.value && !savedSignature.value) {
		ElMessage.warning('请先在画布上书写签名')
		return
	}

	const dataURL = exportSignatureDataURL()

	const base64Data = dataURL.split(',')[1]
	const byteCharacters = atob(base64Data)
	const byteNumbers = new Array(byteCharacters.length)
	for (let i = 0; i < byteCharacters.length; i++) {
		byteNumbers[i] = byteCharacters.charCodeAt(i)
	}
	const byteArray = new Uint8Array(byteNumbers)
	const blob = new Blob([byteArray], { type: 'image/png' })

	const file = new File([blob], `${userStore.user.username}.png`, { type: 'image/png' })

	const formData = new FormData()
	formData.append('file', file)

	const { data } = await uploadImg(formData)
	savedSignature.value = dataURL

	await useUserSignatureApi({ signature: data.url })

	ElMessage.success('签名已保存')
}

const loadSignatureToCanvas = (imageUrl: string) => {
	if (!ctx || !canvasRef.value) {
		return
	}

	const img = new Image()
	img.crossOrigin = 'anonymous'
	img.onload = () => {
		if (ctx && canvasRef.value) {
			ctx.clearRect(0, 0, canvasRef.value.width, canvasRef.value.height)
			ctx.drawImage(img, 0, 0, canvasRef.value.width, canvasRef.value.height)
			applyPenStyle()
			hasInk.value = true
		}
	}
	img.onerror = error => {
		console.error('加载签名图片失败:', error)
	}
	img.src = imageUrl
}

const loadSavedSignature = () => {
	try {
		const signature = userStore.user?.signature
		if (signature) {
			savedSignature.value = signature
			setTimeout(() => {
				loadSignatureToCanvas(signature)
			}, 100)
		}
	} catch (error) {
		console.error('加载签名失败:', error)
	}
}
</script>

<style scoped lang="scss">
.signature-container {
	animation: panel-in 0.28s ease;
}

@keyframes panel-in {
	from {
		opacity: 0;
		transform: translateY(6px);
	}
	to {
		opacity: 1;
		transform: none;
	}
}

.panel-hint {
	display: flex;
	align-items: center;
	gap: 8px;
	margin-bottom: 16px;
	padding: 12px 14px;
	border-radius: 14px;
	font-size: 12.5px;
	color: #5f7386;
	background: linear-gradient(135deg, rgba(0, 168, 232, 0.08), rgba(62, 198, 255, 0.04));
	border: 1px solid rgba(0, 168, 232, 0.12);
}

.hint-dot {
	width: 7px;
	height: 7px;
	border-radius: 50%;
	background: #00a8e8;
	box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.15);
}

.signature-layout {
	display: grid;
	grid-template-columns: minmax(0, 1.5fr) 240px;
	gap: 14px;
	align-items: start;
}

.canvas-panel {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.toolbar {
	display: flex;
	flex-direction: column;
	gap: 12px;
	padding: 12px;
	border-radius: 16px;
	background: #f7fbfe;
	border: 1px solid #e4eef6;
}

.tool-row {
	display: flex;
	flex-direction: column;
	gap: 8px;

	&.compact {
		flex-direction: row;
		flex-wrap: wrap;
		align-items: center;
		justify-content: space-between;
		gap: 12px 18px;
	}
}

.tool-group {
	display: flex;
	align-items: center;
	gap: 8px;
	flex-wrap: wrap;
}

.tool-label {
	font-size: 12px;
	font-weight: 650;
	color: #64748b;
}

.tip-picker {
	display: grid;
	grid-template-columns: repeat(4, minmax(0, 1fr));
	gap: 8px;
}

.tip-option {
	display: flex;
	flex-direction: column;
	align-items: stretch;
	gap: 6px;
	padding: 8px 8px 9px;
	border-radius: 14px;
	border: 1px solid #e2e8f0;
	background: #fff;
	color: #475569;
	cursor: pointer;
	text-align: left;
	transition: border-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease, background 0.18s ease;

	&:hover {
		transform: translateY(-1px);
		border-color: rgba(0, 168, 232, 0.35);
	}

	&.active {
		border-color: #00a8e8;
		background: linear-gradient(180deg, #f3faff, #fff);
		box-shadow: 0 8px 18px rgba(0, 168, 232, 0.12);

		.tip-preview {
			color: #00a8e8;
			background: rgba(0, 168, 232, 0.08);
		}

		.tip-meta strong {
			color: #007eb8;
		}
	}
}

.tip-preview {
	display: grid;
	place-items: center;
	height: 34px;
	border-radius: 10px;
	color: #64748b;
	background: #f8fafc;
	transition: color 0.18s ease, background 0.18s ease;

	:deep(svg) {
		width: 48px;
		height: 24px;
		display: block;
	}
}

.tip-meta {
	display: flex;
	flex-direction: column;
	gap: 1px;
	min-width: 0;
	padding: 0 2px;

	strong {
		font-size: 12.5px;
		font-weight: 700;
		color: #122033;
		line-height: 1.2;
	}

	em {
		font-style: normal;
		font-size: 11px;
		color: #94a3b8;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}
}

.chip {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	height: 28px;
	padding: 0 10px;
	border-radius: 999px;
	border: 1px solid #e2e8f0;
	background: #fff;
	color: #475569;
	font-size: 12px;
	cursor: pointer;

	&.active {
		border-color: #00a8e8;
		color: #007eb8;
		background: rgba(0, 168, 232, 0.1);
		font-weight: 650;
	}
}

.chip-dot {
	border-radius: 50%;
	background: currentColor;
	flex-shrink: 0;
}

.cursor-chip {
	padding-left: 8px;
}

.cursor-preview {
	width: 14px;
	height: 14px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	color: currentColor;
	flex-shrink: 0;

	:deep(svg) {
		width: 14px;
		height: 14px;
		display: block;
	}
}

.color-dot {
	width: 22px;
	height: 22px;
	border-radius: 50%;
	border: 2px solid #fff;
	box-shadow: 0 0 0 1px #d7e3ee;
	cursor: pointer;

	&.active {
		box-shadow: 0 0 0 2px #00a8e8;
	}
}

@media (max-width: 720px) {
	.tip-picker {
		grid-template-columns: repeat(2, minmax(0, 1fr));
	}
}

.canvas-wrapper {
	position: relative;
	width: 100%;
	overflow: hidden;
	border-radius: 18px;
	border: 1px dashed rgba(0, 168, 232, 0.35);
	background:
		linear-gradient(180deg, #ffffff, #f7fafc),
		radial-gradient(circle at 1px 1px, rgba(0, 168, 232, 0.08) 1px, transparent 0);
	background-size: auto, 18px 18px;
	box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.8);
	transition: border-color 0.18s ease, box-shadow 0.18s ease;

	&.drawing {
		border-color: rgba(0, 168, 232, 0.55);
		box-shadow: 0 0 0 3px rgba(0, 168, 232, 0.1);
	}
}

.canvas-label {
	position: absolute;
	top: 12px;
	left: 14px;
	z-index: 1;
	padding: 3px 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 650;
	color: #0090c8;
	background: rgba(255, 255, 255, 0.88);
	border: 1px solid rgba(0, 168, 232, 0.16);
	pointer-events: none;
}

.canvas-guide {
	position: absolute;
	left: 50%;
	top: 50%;
	transform: translate(-50%, -50%);
	z-index: 2;
	font-size: 18px;
	font-weight: 600;
	letter-spacing: 0.12em;
	color: rgba(148, 163, 184, 0.42);
	pointer-events: none;
	user-select: none;
}

.signature-canvas {
	position: relative;
	z-index: 1;
	display: block;
	width: 100%;
	touch-action: none;
	background: transparent;
}

.signature-actions {
	display: flex;
	justify-content: flex-end;
	gap: 10px;
}

.btn {
	min-width: 108px;
	height: 40px;
	padding: 0 16px;
	border-radius: 12px;
	border: none;
	font-size: 13.5px;
	font-weight: 650;
	cursor: pointer;
	transition: all 0.2s ease;

	&.ghost {
		color: #475569;
		background: #f1f5f9;

		&:hover {
			background: #e2e8f0;
		}
	}

	&.primary {
		color: #fff;
		background: linear-gradient(135deg, #00a8e8, #2bbef5);
		box-shadow: 0 10px 22px rgba(0, 168, 232, 0.28);

		&:hover {
			filter: brightness(1.04);
		}
	}
}

.side-panel {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.preview-card,
.tip-card {
	padding: 14px;
	border-radius: 16px;
	background: #f8fbfd;
	border: 1px solid #eaf1f7;
}

.preview-head {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 10px;

	strong {
		font-size: 13px;
		color: #122033;
	}
	em {
		font-style: normal;
		font-size: 12px;
		color: #00a8e8;
		font-weight: 650;
	}
}

.preview-box {
	height: 120px;
	border-radius: 12px;
	background: #fff;
	border: 1px solid #e8eef5;
	overflow: hidden;
	display: grid;
	place-items: center;

	img {
		width: 100%;
		height: 100%;
		object-fit: contain;
		background: #fff;
	}
}

.preview-empty {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 6px;
	color: #94a3b8;
	font-size: 12px;

	svg {
		width: 40px;
		height: 40px;
	}
}

.tip-card {
	strong {
		display: block;
		margin-bottom: 8px;
		font-size: 13px;
		color: #122033;
	}

	ul {
		margin: 0;
		padding-left: 16px;
		color: #64748b;
		font-size: 12px;
		line-height: 1.7;
	}
}

@media (max-width: 900px) {
	.signature-layout {
		grid-template-columns: 1fr;
	}
}
</style>
