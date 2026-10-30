<template>
	<Teleport to="body">
		<transition name="login-load">
			<div v-if="visible" class="login-loading" role="status" aria-live="polite" aria-label="登录中">
				<div class="load-bg" aria-hidden="true">
					<span class="orb o1"></span>
					<span class="orb o2"></span>
					<span class="grid"></span>
				</div>

				<div class="load-card">
					<div class="ring-wrap" aria-hidden="true">
						<span class="ring r1"></span>
						<span class="ring r2"></span>
						<span class="ring r3"></span>
						<div class="logo-core">
							<img src="/logo.png" alt="" />
						</div>
					</div>

					<strong class="title">登录中</strong>
					<p class="desc">{{ tip }}</p>

					<div class="bar" aria-hidden="true">
						<span class="bar-fill"></span>
					</div>

					<ul class="steps">
						<li :class="{ on: step >= 1 }">校验账号</li>
						<li :class="{ on: step >= 2 }">建立会话</li>
						<li :class="{ on: step >= 3 }">进入控制台</li>
					</ul>
				</div>
			</div>
		</transition>
	</Teleport>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from 'vue'

const props = defineProps<{
	visible: boolean
}>()

const tips = ['正在核验身份信息…', '正在加密建立安全连接…', '正在加载工作台资源…', '即将进入 ICEJZ 控制台…']
const tipIndex = ref(0)
const step = ref(1)
let tipTimer: number | undefined
let stepTimer: number | undefined

const tip = computed(() => tips[tipIndex.value])

const clearTimers = () => {
	if (tipTimer) window.clearInterval(tipTimer)
	if (stepTimer) window.clearInterval(stepTimer)
	tipTimer = undefined
	stepTimer = undefined
}

watch(
	() => props.visible,
	val => {
		clearTimers()
		if (!val) {
			tipIndex.value = 0
			step.value = 1
			return
		}
		tipIndex.value = 0
		step.value = 1
		tipTimer = window.setInterval(() => {
			tipIndex.value = (tipIndex.value + 1) % tips.length
		}, 1200)
		stepTimer = window.setInterval(() => {
			step.value = step.value >= 3 ? 1 : step.value + 1
		}, 900)
	},
	{ immediate: true }
)

onBeforeUnmount(clearTimers)
</script>

<style scoped lang="scss">
.login-loading {
	position: fixed;
	inset: 0;
	z-index: 5000;
	display: grid;
	place-items: center;
	background: rgba(8, 24, 40, 0.42);
	backdrop-filter: blur(10px);
}

.load-bg {
	position: absolute;
	inset: 0;
	overflow: hidden;
	pointer-events: none;
}

.orb {
	position: absolute;
	border-radius: 50%;
	filter: blur(40px);
	opacity: 0.55;

	&.o1 {
		width: 320px;
		height: 320px;
		left: 12%;
		top: 18%;
		background: rgba(0, 168, 232, 0.45);
		animation: float-orb 5s ease-in-out infinite;
	}
	&.o2 {
		width: 260px;
		height: 260px;
		right: 14%;
		bottom: 16%;
		background: rgba(62, 198, 255, 0.35);
		animation: float-orb 6.5s ease-in-out infinite reverse;
	}
}

.grid {
	position: absolute;
	inset: 0;
	background-image:
		linear-gradient(rgba(255, 255, 255, 0.04) 1px, transparent 1px),
		linear-gradient(90deg, rgba(255, 255, 255, 0.04) 1px, transparent 1px);
	background-size: 36px 36px;
	mask-image: radial-gradient(circle at center, #000 20%, transparent 75%);
	opacity: 0.5;
}

.load-card {
	position: relative;
	z-index: 1;
	width: min(360px, calc(100vw - 40px));
	padding: 28px 26px 24px;
	border-radius: 22px;
	text-align: center;
	background: rgba(255, 255, 255, 0.9);
	border: 1px solid rgba(0, 168, 232, 0.18);
	box-shadow: 0 24px 60px rgba(8, 24, 40, 0.28);
	backdrop-filter: blur(16px);
	animation: card-in 0.35s ease both;
}

.ring-wrap {
	position: relative;
	width: 96px;
	height: 96px;
	margin: 0 auto 18px;
}

.ring {
	position: absolute;
	inset: 0;
	border-radius: 50%;
	border: 2px solid transparent;

	&.r1 {
		border-top-color: #00a8e8;
		border-right-color: rgba(0, 168, 232, 0.25);
		animation: spin 1.1s linear infinite;
	}
	&.r2 {
		inset: 8px;
		border-bottom-color: #3ec6ff;
		border-left-color: rgba(62, 198, 255, 0.2);
		animation: spin 1.6s linear infinite reverse;
	}
	&.r3 {
		inset: 16px;
		border-top-color: rgba(0, 144, 200, 0.55);
		animation: spin 2.2s linear infinite;
	}
}

.logo-core {
	position: absolute;
	inset: 24px;
	border-radius: 50%;
	display: grid;
	place-items: center;
	background: linear-gradient(160deg, #fff, #e8f7fd);
	box-shadow: 0 8px 18px rgba(0, 168, 232, 0.2);

	img {
		width: 28px;
		height: 28px;
		object-fit: contain;
	}
}

.title {
	display: block;
	font-size: 20px;
	font-weight: 760;
	color: #0f1724;
	letter-spacing: 0.12em;
}

.desc {
	margin: 8px 0 16px;
	min-height: 20px;
	font-size: 13px;
	color: #5f7386;
}

.bar {
	height: 6px;
	border-radius: 999px;
	overflow: hidden;
	background: #e8eef5;
	margin-bottom: 16px;
}

.bar-fill {
	display: block;
	height: 100%;
	width: 40%;
	border-radius: inherit;
	background: linear-gradient(90deg, #00a8e8, #3ec6ff, #00a8e8);
	background-size: 200% 100%;
	animation: bar-run 1.2s ease-in-out infinite;
}

.steps {
	list-style: none;
	margin: 0;
	padding: 0;
	display: flex;
	justify-content: space-between;
	gap: 8px;

	li {
		flex: 1;
		position: relative;
		padding-top: 14px;
		font-size: 11px;
		color: #94a3b8;
		transition: color 0.2s ease;

		&::before {
			content: '';
			position: absolute;
			top: 0;
			left: 50%;
			transform: translateX(-50%);
			width: 8px;
			height: 8px;
			border-radius: 50%;
			background: #d5e3ee;
			transition: all 0.2s ease;
		}

		&.on {
			color: #007eb8;
			font-weight: 650;

			&::before {
				background: #00a8e8;
				box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.16);
			}
		}
	}
}

.login-load-enter-active,
.login-load-leave-active {
	transition: opacity 0.28s ease;
}
.login-load-enter-from,
.login-load-leave-to {
	opacity: 0;
}

@keyframes spin {
	to {
		transform: rotate(360deg);
	}
}

@keyframes bar-run {
	0% {
		transform: translateX(-30%);
		background-position: 0% 0;
	}
	50% {
		transform: translateX(160%);
		background-position: 100% 0;
	}
	100% {
		transform: translateX(-30%);
		background-position: 0% 0;
	}
}

@keyframes float-orb {
	0%,
	100% {
		transform: translateY(0);
	}
	50% {
		transform: translateY(-18px);
	}
}

@keyframes card-in {
	from {
		opacity: 0;
		transform: translateY(10px) scale(0.98);
	}
	to {
		opacity: 1;
		transform: none;
	}
}
</style>
