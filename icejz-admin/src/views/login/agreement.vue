<template>
	<div class="agreement-bar">
		<label class="agree-check">
			<input v-model="agreed" type="checkbox" @change="onCheckChange" />
			<span class="box" :class="{ on: agreed }" aria-hidden="true"></span>
			<span class="text">
				我已阅读并同意
				<template v-for="(item, index) in AGREEMENTS" :key="item.id">
					<button type="button" class="link" @click.prevent="openDialog(item.id)">
						《{{ item.shortTitle }}》
					</button>
					<span v-if="index < AGREEMENTS.length - 1" class="sep">、</span>
				</template>
			</span>
		</label>
		<p class="agree-hint">登录前须完整阅读上述协议并勾选同意</p>
	</div>

	<Teleport to="body">
		<Transition name="agree-fade">
			<div v-if="visible" class="agreement-overlay" role="dialog" aria-modal="true" @click.self="visible = false">
				<div class="agreement-modal">
					<header class="modal-head">
						<div class="modal-head-main">
							<span class="modal-badge">协议阅读</span>
							<h3 class="modal-title">{{ current?.title }}</h3>
							<p class="modal-meta">
								<span>更新日期：{{ current?.updatedAt }}</span>
								<span class="dot">·</span>
								<span>已读 {{ readCount }}/{{ AGREEMENTS.length }}</span>
							</p>
						</div>
						<button type="button" class="modal-close" aria-label="关闭" @click="visible = false">
							<svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">
								<path
									fill="currentColor"
									d="M18.3 5.71a1 1 0 0 0-1.41 0L12 10.59 7.11 5.7A1 1 0 0 0 5.7 7.11L10.59 12l-4.9 4.89a1 1 0 1 0 1.41 1.42L12 13.41l4.89 4.9a1 1 0 0 0 1.42-1.41L13.41 12l4.9-4.89a1 1 0 0 0-.01-1.4Z"
								/>
							</svg>
						</button>
					</header>

					<div class="modal-tabs">
						<button
							v-for="item in AGREEMENTS"
							:key="item.id"
							type="button"
							:class="['tab', { active: activeId === item.id, read: !!readMap[item.id] }]"
							@click="switchTab(item.id)"
						>
							<span class="tab-dot"></span>
							{{ item.shortTitle }}
						</button>
					</div>

					<div class="modal-progress">
						<i :style="{ width: `${(readCount / AGREEMENTS.length) * 100}%` }"></i>
					</div>

					<div ref="bodyRef" class="modal-body" @scroll="onScroll">
						<section v-for="(sec, idx) in current?.sections || []" :key="idx" class="section">
							<h4>{{ sec.heading }}</h4>
							<p v-for="(p, pIdx) in sec.paragraphs" :key="pIdx">{{ p }}</p>
						</section>
						<div class="read-hint" :class="{ done: readDone }">
							{{ readDone ? '已阅读至底部，可确认同意本协议' : '请下滑阅读完整协议内容' }}
						</div>
					</div>

					<footer class="modal-foot">
						<span class="foot-tip">确认即表示您理解并接受本协议条款</span>
						<div class="foot-actions">
							<button type="button" class="btn ghost" @click="visible = false">关闭</button>
							<button type="button" class="btn primary" :disabled="!readDone" @click="confirmAgree">
								{{ confirmBtnText }}
							</button>
						</div>
					</footer>
				</div>
			</div>
		</Transition>
	</Teleport>
</template>

<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { AGREEMENTS, AGREEMENT_STORAGE_KEY } from './agreements'

const emit = defineEmits<{
	(e: 'update:modelValue', v: boolean): void
}>()

const props = defineProps<{
	modelValue?: boolean
}>()

const stored = (() => {
	try {
		return localStorage.getItem(AGREEMENT_STORAGE_KEY) === '1'
	} catch {
		return false
	}
})()

const agreed = ref(typeof props.modelValue === 'boolean' ? props.modelValue : stored)
const visible = ref(false)
const activeId = ref(AGREEMENTS[0].id)
const readDone = ref(false)
const bodyRef = ref<HTMLElement | null>(null)
const readMap = ref<Record<string, boolean>>(
	stored ? Object.fromEntries(AGREEMENTS.map(a => [a.id, true])) : {}
)

const current = computed(() => AGREEMENTS.find(a => a.id === activeId.value) || AGREEMENTS[0])
const readCount = computed(() => AGREEMENTS.filter(a => readMap.value[a.id]).length)
const confirmBtnText = computed(() => {
	if (!readDone.value) {
		return '请先阅读完整内容'
	}
	const remain = AGREEMENTS.length - readCount.value - (readMap.value[activeId.value] ? 0 : 1)
	if (remain > 0 || !AGREEMENTS.every(a => readMap.value[a.id] || a.id === activeId.value)) {
		return '同意并阅读下一份'
	}
	return '已阅读并同意全部协议'
})

watch(
	() => props.modelValue,
	v => {
		if (typeof v === 'boolean') {
			agreed.value = v
		}
	}
)

onMounted(() => {
	emit('update:modelValue', agreed.value)
})

const persist = (val: boolean) => {
	try {
		if (val) {
			localStorage.setItem(AGREEMENT_STORAGE_KEY, '1')
		} else {
			localStorage.removeItem(AGREEMENT_STORAGE_KEY)
		}
	} catch {
		/* ignore */
	}
}

const onCheckChange = () => {
	if (agreed.value) {
		const unread = AGREEMENTS.filter(a => !readMap.value[a.id])
		if (unread.length) {
			agreed.value = false
			ElMessage.warning(`请先阅读《${unread[0].shortTitle}》`)
			openDialog(unread[0].id)
			return
		}
	}
	persist(agreed.value)
	emit('update:modelValue', agreed.value)
}

const checkScrollBottom = () => {
	const el = bodyRef.value
	if (!el) {
		return
	}
	const reached = el.scrollTop + el.clientHeight >= el.scrollHeight - 16
	if (reached) {
		readDone.value = true
		readMap.value = { ...readMap.value, [activeId.value]: true }
	}
}

const onScroll = () => {
	checkScrollBottom()
}

const resetScroll = async () => {
	const alreadyRead = !!readMap.value[activeId.value]
	readDone.value = alreadyRead
	await nextTick()
	const el = bodyRef.value
	if (!el) {
		return
	}
	if (!alreadyRead) {
		el.scrollTop = 0
		await nextTick()
		if (el.scrollHeight <= el.clientHeight + 4) {
			readDone.value = true
			readMap.value = { ...readMap.value, [activeId.value]: true }
		}
	}
}

const openDialog = async (id: string) => {
	activeId.value = id
	visible.value = true
	await nextTick()
	await nextTick()
	await resetScroll()
}

const switchTab = async (id: string) => {
	activeId.value = id
	await resetScroll()
}

const confirmAgree = () => {
	readMap.value = { ...readMap.value, [activeId.value]: true }
	const allRead = AGREEMENTS.every(a => readMap.value[a.id])
	if (!allRead) {
		const next = AGREEMENTS.find(a => !readMap.value[a.id])
		ElMessage.success(`已同意《${current.value.shortTitle}》，请继续阅读其余协议`)
		if (next) {
			switchTab(next.id)
		}
		return
	}
	agreed.value = true
	persist(true)
	emit('update:modelValue', true)
	visible.value = false
	ElMessage.success('已阅读并同意全部协议')
}

watch(visible, v => {
	if (v) {
		document.body.style.overflow = 'hidden'
	} else {
		document.body.style.overflow = ''
		readDone.value = false
	}
})

onUnmounted(() => {
	document.body.style.overflow = ''
})

const ensureAgreed = () => {
	if (agreed.value) {
		return true
	}
	ElMessage.warning('请先阅读并同意相关协议')
	const firstUnread = AGREEMENTS.find(a => !readMap.value[a.id]) || AGREEMENTS[0]
	openDialog(firstUnread.id)
	return false
}

defineExpose({ ensureAgreed, agreed })
</script>

<style lang="scss" scoped>
.agreement-bar {
	margin: 2px 0 10px;
}

.agree-check {
	display: flex;
	align-items: flex-start;
	gap: 8px;
	cursor: pointer;
	user-select: none;

	input {
		position: absolute;
		opacity: 0;
		pointer-events: none;
	}

	.box {
		width: 16px;
		height: 16px;
		margin-top: 2px;
		flex-shrink: 0;
		border-radius: 4px;
		border: 1.5px solid #c5d5e2;
		background: #fff;
		position: relative;
		transition: all 0.2s ease;

		&.on {
			border-color: #00a8e8;
			background: linear-gradient(135deg, #00a8e8, #3ec6ff);

			&::after {
				content: '';
				position: absolute;
				left: 4px;
				top: 1px;
				width: 4px;
				height: 8px;
				border: solid #fff;
				border-width: 0 2px 2px 0;
				transform: rotate(45deg);
			}
		}
	}

	.text {
		font-size: 12.5px;
		line-height: 1.65;
		color: #6b7c8d;
	}

	.sep {
		color: #a8b4c0;
	}

	.link {
		display: inline;
		padding: 0;
		margin: 0;
		border: none;
		background: none;
		color: #0090c8;
		font-size: inherit;
		cursor: pointer;
		transition: color 0.2s ease;

		&:hover {
			color: #00a8e8;
			text-decoration: underline;
		}
	}
}

.agree-hint {
	margin: 6px 0 0 24px;
	font-size: 11.5px;
	color: #9aa8b5;
}

</style>

<style lang="scss">
.agreement-overlay {
	position: fixed;
	inset: 0;
	z-index: 4000;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 24px 16px;
	background: rgba(8, 18, 32, 0.55);
	backdrop-filter: blur(8px);
	-webkit-backdrop-filter: blur(8px);
}

.agreement-modal {
	display: flex;
	flex-direction: column;
	width: min(860px, 100%);
	max-height: min(88vh, 820px);
	border-radius: 20px;
	overflow: hidden;
	background:
		radial-gradient(120% 80% at 0% 0%, rgba(0, 168, 232, 0.08), transparent 45%),
		linear-gradient(180deg, #ffffff, #f7fafc);
	box-shadow:
		0 28px 80px rgba(8, 18, 32, 0.28),
		0 0 0 1px rgba(255, 255, 255, 0.5) inset;
}

.modal-head {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	gap: 16px;
	padding: 22px 24px 12px;
}

.modal-head-main {
	min-width: 0;
}

.modal-badge {
	display: inline-flex;
	align-items: center;
	padding: 3px 10px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 700;
	letter-spacing: 0.4px;
	color: #0090c8;
	background: rgba(0, 168, 232, 0.1);
	border: 1px solid rgba(0, 168, 232, 0.18);
}

.modal-title {
	margin: 10px 0 6px;
	font-size: 20px;
	font-weight: 750;
	line-height: 1.35;
	color: #0f1724;
}

.modal-meta {
	display: flex;
	align-items: center;
	flex-wrap: wrap;
	gap: 6px;
	margin: 0;
	font-size: 12.5px;
	color: #8b93a7;

	.dot {
		opacity: 0.5;
	}
}

.modal-close {
	flex-shrink: 0;
	width: 36px;
	height: 36px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	border: none;
	border-radius: 10px;
	background: #f1f5f9;
	color: #64748b;
	cursor: pointer;
	transition: all 0.2s ease;

	&:hover {
		background: #e2e8f0;
		color: #0f1724;
	}
}

.modal-tabs {
	display: grid;
	grid-template-columns: repeat(4, minmax(0, 1fr));
	gap: 6px;
	margin: 0 24px 12px;
	padding: 4px;
	border-radius: 12px;
	background: #eef4f9;

	@media (max-width: 640px) {
		grid-template-columns: repeat(2, minmax(0, 1fr));
	}
}

.agreement-modal .tab {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 5px;
	border: none;
	background: transparent;
	padding: 10px 4px;
	border-radius: 9px;
	font-size: 12.5px;
	font-weight: 600;
	color: #7a8796;
	cursor: pointer;
	transition: all 0.2s ease;

	.tab-dot {
		width: 6px;
		height: 6px;
		border-radius: 50%;
		background: #c5d3de;
	}

	&.read .tab-dot {
		background: #10b981;
		box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
	}

	&.active {
		background: #fff;
		color: #0090c8;
		box-shadow: 0 4px 12px rgba(15, 23, 36, 0.06);
	}
}

.modal-progress {
	height: 3px;
	margin: 0 24px 12px;
	border-radius: 999px;
	background: #e8eef4;
	overflow: hidden;

	i {
		display: block;
		height: 100%;
		border-radius: inherit;
		background: linear-gradient(90deg, #00a8e8, #3ec6ff);
		transition: width 0.3s ease;
	}
}

.modal-body {
	flex: 1;
	min-height: 280px;
	overflow: auto;
	margin: 0 24px;
	padding: 4px 4px 8px;
	border-radius: 14px;
	border: 1px solid #e6eef5;
	background: linear-gradient(180deg, #fbfdff, #f7fafc);
}

.agreement-modal .section {
	padding: 14px 16px 4px;

	h4 {
		margin: 0 0 8px;
		font-size: 14.5px;
		color: #111827;
	}

	p {
		margin: 0 0 10px;
		font-size: 13.5px;
		line-height: 1.8;
		color: #4b5565;
		text-align: justify;
	}
}

.agreement-modal .read-hint {
	margin: 8px 16px 16px;
	padding: 11px 12px;
	border-radius: 10px;
	font-size: 12.5px;
	text-align: center;
	color: #8b93a7;
	background: rgba(0, 168, 232, 0.06);
	border: 1px dashed rgba(0, 168, 232, 0.22);

	&.done {
		color: #059669;
		background: rgba(16, 185, 129, 0.08);
		border-color: rgba(16, 185, 129, 0.28);
	}
}

.modal-foot {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
	flex-wrap: wrap;
	padding: 14px 24px 20px;
	border-top: 1px solid rgba(226, 232, 240, 0.9);
	background: rgba(255, 255, 255, 0.72);
}

.agreement-modal .foot-tip {
	font-size: 12.5px;
	color: #9aa8b5;
}

.agreement-modal .foot-actions {
	display: flex;
	gap: 10px;
	margin-left: auto;
}

.agreement-modal .btn {
	min-width: 96px;
	height: 38px;
	padding: 0 16px;
	border-radius: 10px;
	border: none;
	font-size: 13.5px;
	font-weight: 600;
	cursor: pointer;
	transition: all 0.2s ease;

	&.ghost {
		background: #f1f5f9;
		color: #475569;

		&:hover {
			background: #e2e8f0;
		}
	}

	&.primary {
		color: #fff;
		background: linear-gradient(135deg, #00a8e8, #2bbef5);
		box-shadow: 0 8px 20px rgba(0, 168, 232, 0.28);

		&:hover:not(:disabled) {
			filter: brightness(1.04);
		}

		&:disabled {
			opacity: 0.45;
			cursor: not-allowed;
			box-shadow: none;
		}
	}
}

.agree-fade-enter-active,
.agree-fade-leave-active {
	transition: opacity 0.22s ease;

	.agreement-modal {
		transition: transform 0.22s ease, opacity 0.22s ease;
	}
}

.agree-fade-enter-from,
.agree-fade-leave-to {
	opacity: 0;

	.agreement-modal {
		opacity: 0;
		transform: translateY(12px) scale(0.98);
	}
}

@media (max-width: 640px) {
	.agreement-overlay {
		padding: 12px;
		align-items: flex-end;
	}

	.agreement-modal {
		max-height: 92vh;
		border-radius: 18px 18px 14px 14px;
	}

	.modal-head {
		padding: 18px 16px 10px;
	}

	.modal-tabs,
	.modal-progress,
	.modal-body {
		margin-left: 16px;
		margin-right: 16px;
	}

	.modal-foot {
		padding: 12px 16px 16px;
	}

	.modal-title {
		font-size: 17px;
	}
}
</style>
