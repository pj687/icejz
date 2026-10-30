<template>
	<div
		ref="pageRef"
		class="login-page"
		:style="spotlightStyle"
		@mousemove="onMouseMove"
		@mouseleave="onMouseLeave"
	>
		<div class="bg-layer" aria-hidden="true">
			<div class="bg-base"></div>
			<div class="bg-stars"></div>
			<div class="bg-mesh"></div>
			<div class="bg-aurora a1"></div>
			<div class="bg-aurora a2"></div>
			<div class="bg-aurora a3"></div>
			<div class="bg-glow g1"></div>
			<div class="bg-glow g2"></div>
			<div class="bg-glow g3"></div>
			<canvas ref="canvasRef" class="bg-canvas"></canvas>

			<div class="scene-3d">
				<div class="scene-world">
					<div class="floor-grid"></div>
					<div class="floor-glow"></div>
					<div class="orbit-track ot1"></div>
					<div class="orbit-track ot2"></div>
					<div class="orbit-track ot3"></div>

					<div class="core-hub">
						<span class="hub-glow"></span>
						<div class="hub-cube">
							<span class="hc f-front"></span>
							<span class="hc f-back"></span>
							<span class="hc f-right"></span>
							<span class="hc f-left"></span>
							<span class="hc f-top"></span>
							<span class="hc f-bottom"></span>
						</div>
						<span class="hub-ring r-a"></span>
						<span class="hub-ring r-b"></span>
						<span class="hub-scan"></span>
					</div>

					<div class="tech-orbit to1">
						<div class="tech-item chip-item">
							<div class="mesh chip-3d">
								<span class="face front">
									<span class="die">
										<span class="die-grid"></span>
										<span class="die-core"></span>
										<span class="die-scan"></span>
									</span>
									<span class="mark"></span>
								</span>
								<span class="face back"></span>
								<span class="face right"></span>
								<span class="face left"></span>
								<span class="face top"></span>
								<span class="face bottom"></span>
								<span class="pins side-l"><em></em><em></em><em></em></span>
								<span class="pins side-r"><em></em><em></em><em></em></span>
								<span class="pins side-t"><em></em><em></em><em></em></span>
								<span class="pins side-b"><em></em><em></em><em></em></span>
							</div>
						</div>
					</div>
					<div class="tech-orbit to2">
						<div class="tech-item server-item">
							<div class="mesh server-3d">
								<span class="face front">
									<span class="bezel"></span>
									<span class="bay b1"><i></i><em></em></span>
									<span class="bay b2"><i></i><em></em></span>
									<span class="bay b3"><i></i><em></em></span>
									<span class="bay b4"><i></i><em></em></span>
									<span class="rail"></span>
									<span class="pwr"></span>
									<span class="led l1"></span>
									<span class="led l2"></span>
									<span class="led l3"></span>
									<span class="vent"></span>
								</span>
								<span class="face back">
									<span class="port p1"></span>
									<span class="port p2"></span>
									<span class="port p3"></span>
								</span>
								<span class="face right">
									<span class="side-vent"></span>
								</span>
								<span class="face left">
									<span class="side-vent"></span>
								</span>
								<span class="face top">
									<span class="top-logo"></span>
								</span>
								<span class="face bottom"></span>
							</div>
						</div>
					</div>
					<div class="tech-orbit to3">
						<div class="tech-item atom-item">
							<div class="mesh atom-3d">
								<span class="atom-core"></span>
								<span class="atom-glow"></span>
								<span class="atom-ring r1"><em></em></span>
								<span class="atom-ring r2"><em></em></span>
								<span class="atom-ring r3"><em></em></span>
							</div>
						</div>
					</div>
					<div class="tech-orbit to4">
						<div class="tech-item sat-item">
							<div class="mesh sat-3d">
								<div class="sat-body-3d">
									<span class="face front"><i></i></span>
									<span class="face back"></span>
									<span class="face right"></span>
									<span class="face left"></span>
									<span class="face top"></span>
									<span class="face bottom"></span>
								</div>
								<span class="sat-panel left"><i></i><i></i><i></i></span>
								<span class="sat-panel right"><i></i><i></i><i></i></span>
								<span class="sat-boom left"></span>
								<span class="sat-boom right"></span>
								<span class="sat-antenna"></span>
							</div>
						</div>
					</div>

					<div class="signal sg1"></div>
					<div class="signal sg2"></div>
					<div class="signal sg3"></div>
					<div class="signal sg4"></div>
					<div class="signal sg5"></div>
					<div class="signal sg6"></div>
				</div>
			</div>

			<span v-for="n in 8" :key="'m' + n" class="meteor" :class="'m' + n"></span>
			<div class="bg-scan"></div>
			<div class="bg-vignette"></div>
			<div class="bg-spotlight"></div>
		</div>

		<header class="login-topbar">
			<div class="topbar-brand">
				<img src="/logo.png" alt="ICEJZ" class="topbar-logo" />
				<div class="topbar-text">
					<span class="topbar-name">ICEJZ</span>
					<span class="topbar-sub">Admin Console</span>
				</div>
			</div>
			<div class="topbar-meta">
				<span class="topbar-chip">
					<span class="chip-live"></span>
					安全登录
				</span>
				<span class="topbar-tag">Low Code Platform</span>
			</div>
		</header>

		<main class="login-main">
			<section class="brand-pane">
				<div class="brand-pane-inner" :style="parallax(-16)">
					<p class="brand-eyebrow">
						<span class="eyebrow-mark">
							<span class="eyebrow-dot"></span>
							<span class="eyebrow-ring"></span>
						</span>
						<span class="eyebrow-text">
							<em>ICE</em>CORE
							<span class="eyebrow-sep">·</span>
							低代码引擎
						</span>
					</p>
					<h1 class="brand-hero">
						<span class="hero-text">ICE</span><span class="hero-accent">JZ</span>
					</h1>
					<p class="brand-slogan">
						<span v-for="(ch, i) in sloganChars" :key="i" class="slogan-ch" :style="{ animationDelay: `${0.35 + i * 0.035}s` }">{{ ch }}</span>
						<span class="slogan-caret"></span>
					</p>
					<p class="brand-lead">{{ $t('app.description') }}</p>

					<ul class="brand-points">
						<li
							v-for="(item, index) in features"
							:key="item.title"
							:class="'tone-' + item.tone"
							:style="{ animationDelay: `${0.18 + index * 0.08}s` }"
						>
							<div class="point-plate" :aria-hidden="true">
								<span class="plate-glow"></span>
								<span class="plate-ring"></span>
								<span class="plate-core">{{ item.icon }}</span>
								<span class="plate-tag">0{{ index + 1 }}</span>
							</div>
							<div class="point-body">
								<strong>{{ item.title }}</strong>
								<p>{{ item.desc }}</p>
							</div>
						</li>
					</ul>

					<div class="hud-bar">
						<div class="hud-item" v-for="item in hudStats" :key="item.label">
							<span class="hud-label">{{ item.label }}</span>
							<span class="hud-value">{{ item.value }}</span>
							<span class="hud-line"><i :style="{ width: item.pct }"></i></span>
						</div>
					</div>
				</div>
			</section>

			<section class="form-pane">
				<div class="login-card" @mousemove="onCardMove" @mouseleave="onCardLeave">
					<div class="card-accent"></div>
					<div class="card-glow" aria-hidden="true"></div>
					<div class="card-shine" :style="cardShineStyle" aria-hidden="true"></div>
					<div class="card-ring" aria-hidden="true"></div>
					<div class="card-noise" aria-hidden="true"></div>
					<span class="card-corner c-tl" aria-hidden="true"></span>
					<span class="card-corner c-tr" aria-hidden="true"></span>
					<span class="card-corner c-bl" aria-hidden="true"></span>
					<span class="card-corner c-br" aria-hidden="true"></span>

					<div class="card-head">
						<div class="card-logo-wrap">
							<img src="/logo.png" alt="ICEJZ" class="card-logo" />
							<span class="logo-pulse"></span>
						</div>
						<div class="card-head-text">
							<div class="card-title-row">
								<h2>欢迎登录</h2>
								<span class="card-badge">
									<span class="badge-dot"></span>
									Secure
								</span>
							</div>
							<p>进入 ICEJZ 管理控制台</p>
						</div>
					</div>

					<div class="login-tabs" role="tablist">
						<button
							type="button"
							role="tab"
							:aria-selected="loginType === 'account'"
							:class="['tab-btn', { active: loginType === 'account' }]"
							@click="loginSwitch('account')"
						>
							账号登录
						</button>
						<button
							type="button"
							role="tab"
							:aria-selected="loginType === 'mobile'"
							:class="['tab-btn', { active: loginType === 'mobile' }]"
							@click="loginSwitch('mobile')"
						>
							手机登录
						</button>
						<span class="tab-indicator" :class="{ mobile: loginType === 'mobile' }"></span>
					</div>

					<div class="card-body" :key="loginType">
						<account v-if="loginType === 'account'" />
						<mobile v-else />
					</div>

					<div class="card-agree">
						<agreement ref="agreementRef" v-model="agreed" />
					</div>

					<div class="card-foot">
						<third />
						<div class="card-secure">
							<span class="secure-dot"></span>
							<span>加密传输</span>
							<span class="secure-sep"></span>
							<span>权限隔离</span>
							<span class="secure-sep"></span>
							<span>操作可审计</span>
						</div>
					</div>
				</div>

				<p class="login-footnote">© {{ year }} ICEJZ · 请先阅读并同意相关协议后再登录</p>
			</section>
		</main>

		<LoginLoading :visible="loginLoading" />
		<AssistantFab guest />
		<AssistantPanel guest />
	</div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, provide, ref, watch } from 'vue'
import Account from './account.vue'
import Mobile from './mobile.vue'
import Third from './third.vue'
import Agreement from './agreement.vue'
import LoginLoading from './LoginLoading.vue'
import AssistantFab from '@/components/assistant/AssistantFab.vue'
import AssistantPanel from '@/components/assistant/AssistantPanel.vue'
import { useRoute } from 'vue-router'
import cache from '@/utils/cache'

const year = new Date().getFullYear()
const slogan = '更快交付 · 更稳运行 · 更易扩展'
const sloganChars = slogan.split('')

const features = [
	{ icon: '安', tone: 'secure', title: '安全可靠', desc: '统一认证、细粒度权限与操作审计' },
	{ icon: '快', tone: 'speed', title: '快速开发', desc: '代码生成与模块化能力加速交付' },
	{ icon: '扩', tone: 'scale', title: '灵活扩展', desc: '业务模块可插拔，适配多端场景' },
	{ icon: '创', tone: 'local', title: '支持信创', desc: '面向国产化环境持续适配' }
]

const hudStats = [
	{ label: 'SYS', value: 'ONLINE', pct: '92%' },
	{ label: 'SEC', value: 'A+ GRADE', pct: '98%' },
	{ label: 'LAT', value: '12ms', pct: '76%' }
]

const loginType = ref('account')
const loginSwitch = (type: string) => {
	loginType.value = type
}

const agreed = ref(false)
const agreementRef = ref<{ ensureAgreed: () => boolean } | null>(null)
const ensureAgreement = () => agreementRef.value?.ensureAgreed() ?? false
provide('ensureAgreement', ensureAgreement)

const loginLoading = ref(false)
const setLoginLoading = (val: boolean) => {
	loginLoading.value = val
}
provide('setLoginLoading', setLoginLoading)

const pageRef = ref<HTMLElement | null>(null)
const canvasRef = ref<HTMLCanvasElement | null>(null)
const mouseX = ref(0.5)
const mouseY = ref(0.5)
const cardShine = ref({ x: 50, y: 30 })
let rafId = 0
let reduceMotion = false

const spotlightStyle = computed(() => ({
	'--mx': `${mouseX.value * 100}%`,
	'--my': `${mouseY.value * 100}%`
}))

const cardShineStyle = computed(() => ({
	background: `radial-gradient(420px circle at ${cardShine.value.x}% ${cardShine.value.y}%, rgba(0,168,232,0.2), transparent 42%)`
}))

const parallax = (intensity: number) => {
	if (reduceMotion) {
		return {}
	}
	const x = (mouseX.value - 0.5) * intensity
	const y = (mouseY.value - 0.5) * intensity
	return {
		transform: `translate3d(${x}px, ${y}px, 0)`
	}
}

const onMouseMove = (e: MouseEvent) => {
	if (reduceMotion || !pageRef.value) {
		return
	}
	const rect = pageRef.value.getBoundingClientRect()
	mouseX.value = (e.clientX - rect.left) / rect.width
	mouseY.value = (e.clientY - rect.top) / rect.height
}

const onMouseLeave = () => {
	mouseX.value = 0.5
	mouseY.value = 0.5
}

const onCardMove = (e: MouseEvent) => {
	if (reduceMotion) {
		return
	}
	const el = e.currentTarget as HTMLElement
	const rect = el.getBoundingClientRect()
	cardShine.value = {
		x: ((e.clientX - rect.left) / rect.width) * 100,
		y: ((e.clientY - rect.top) / rect.height) * 100
	}
}

const onCardLeave = () => {
	cardShine.value = { x: 50, y: 30 }
}

const route = useRoute()
watch(
	() => route,
	() => {
		const redirect = route?.query?.redirect as string
		if (redirect && redirect !== '/') {
			cache.setRedirect(redirect)
		} else {
			cache.setRedirect('')
		}
	},
	{ immediate: true }
)

type Particle = {
	x: number
	y: number
	vx: number
	vy: number
	r: number
}

const initParticles = () => {
	const canvas = canvasRef.value
	if (!canvas || reduceMotion) {
		return
	}

	const ctx = canvas.getContext('2d')
	if (!ctx) {
		return
	}

	let particles: Particle[] = []
	let width = 0
	let height = 0

	const resize = () => {
		width = window.innerWidth
		height = window.innerHeight
		const dpr = Math.min(window.devicePixelRatio || 1, 2)
		canvas.width = width * dpr
		canvas.height = height * dpr
		canvas.style.width = `${width}px`
		canvas.style.height = `${height}px`
		ctx.setTransform(dpr, 0, 0, dpr, 0, 0)

		const count = Math.min(80, Math.floor((width * height) / 20000))
		particles = Array.from({ length: count }, () => ({
			x: Math.random() * width,
			y: Math.random() * height,
			vx: (Math.random() - 0.5) * 0.32,
			vy: (Math.random() - 0.5) * 0.32,
			r: Math.random() * 1.8 + 0.5
		}))
	}

	const draw = () => {
		ctx.clearRect(0, 0, width, height)
		const mx = mouseX.value * width
		const my = mouseY.value * height

		for (const p of particles) {
			const dxm = mx - p.x
			const dym = my - p.y
			const dm = Math.hypot(dxm, dym) || 1
			if (dm < 180) {
				p.vx += (dxm / dm) * 0.008
				p.vy += (dym / dm) * 0.008
			}

			p.vx *= 0.992
			p.vy *= 0.992
			p.x += p.vx
			p.y += p.vy
			if (p.x < 0 || p.x > width) {
				p.vx *= -1
			}
			if (p.y < 0 || p.y > height) {
				p.vy *= -1
			}

			ctx.beginPath()
			ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2)
			ctx.fillStyle = 'rgba(160, 230, 255, 0.8)'
			ctx.shadowColor = 'rgba(0, 168, 232, 0.55)'
			ctx.shadowBlur = 8
			ctx.fill()
			ctx.shadowBlur = 0
		}

		for (let i = 0; i < particles.length; i++) {
			for (let j = i + 1; j < particles.length; j++) {
				const a = particles[i]
				const b = particles[j]
				const dx = a.x - b.x
				const dy = a.y - b.y
				const dist = Math.hypot(dx, dy)
				if (dist < 140) {
					const alpha = (1 - dist / 140) * 0.32
					ctx.beginPath()
					ctx.moveTo(a.x, a.y)
					ctx.lineTo(b.x, b.y)
					ctx.strokeStyle = `rgba(0, 168, 232, ${alpha})`
					ctx.lineWidth = 1
					ctx.stroke()
				}
			}
		}

		rafId = requestAnimationFrame(draw)
	}

	resize()
	draw()
	window.addEventListener('resize', resize)

	return () => {
		window.removeEventListener('resize', resize)
		cancelAnimationFrame(rafId)
	}
}

let disposeParticles: (() => void) | undefined

onMounted(() => {
	reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
	disposeParticles = initParticles()
})

onUnmounted(() => {
	disposeParticles?.()
	cancelAnimationFrame(rafId)
})
</script>

<style lang="scss" scoped>
.login-page {
	--login-cyan: #00a8e8;
	--login-cyan-2: #3ec6ff;
	--login-muted: #6b7280;
	--mx: 50%;
	--my: 40%;
	min-height: 100vh;
	position: relative;
	overflow: hidden;
	color: #fff;
	font-family: "Segoe UI", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
}

.bg-layer {
	position: absolute;
	inset: 0;
	pointer-events: none;
	overflow: hidden;
}

.bg-base {
	position: absolute;
	inset: 0;
	background:
		radial-gradient(ellipse 80% 55% at 12% 18%, rgba(0, 168, 232, 0.42), transparent 55%),
		radial-gradient(ellipse 70% 50% at 88% 82%, rgba(62, 198, 255, 0.28), transparent 52%),
		radial-gradient(ellipse 50% 40% at 55% 45%, rgba(14, 60, 92, 0.5), transparent 60%),
		linear-gradient(160deg, #030912 0%, #0a1524 36%, #0e2438 66%, #081c2c 100%);
}

.bg-stars {
	position: absolute;
	inset: 0;
	opacity: 0.55;
	background-image:
		radial-gradient(1.2px 1.2px at 12% 18%, rgba(255, 255, 255, 0.75), transparent),
		radial-gradient(1px 1px at 28% 62%, rgba(183, 233, 255, 0.7), transparent),
		radial-gradient(1.4px 1.4px at 46% 22%, rgba(255, 255, 255, 0.55), transparent),
		radial-gradient(1px 1px at 64% 48%, rgba(154, 230, 255, 0.65), transparent),
		radial-gradient(1.2px 1.2px at 78% 16%, rgba(255, 255, 255, 0.5), transparent),
		radial-gradient(1px 1px at 88% 72%, rgba(122, 217, 255, 0.6), transparent),
		radial-gradient(1.3px 1.3px at 18% 84%, rgba(255, 255, 255, 0.4), transparent),
		radial-gradient(1px 1px at 52% 78%, rgba(183, 233, 255, 0.55), transparent);
	animation: stars-twinkle 6s ease-in-out infinite;
}

.bg-mesh {
	position: absolute;
	inset: 0;
	opacity: 0.18;
	background-image:
		linear-gradient(rgba(0, 168, 232, 0.12) 1px, transparent 1px),
		linear-gradient(90deg, rgba(0, 168, 232, 0.12) 1px, transparent 1px);
	background-size: 72px 72px;
	mask-image: radial-gradient(ellipse at 35% 45%, #000 10%, transparent 68%);
}

.bg-aurora {
	position: absolute;
	width: 58vw;
	height: 58vw;
	border-radius: 42%;
	filter: blur(90px);
	opacity: 0.38;
	mix-blend-mode: screen;
}

.a1 {
	left: -12%;
	top: -18%;
	background: conic-gradient(from 90deg, rgba(0, 168, 232, 0.6), transparent, rgba(62, 198, 255, 0.45), transparent);
	animation: aurora 14s ease-in-out infinite;
}

.a2 {
	right: -20%;
	bottom: -22%;
	background: conic-gradient(from 220deg, rgba(62, 198, 255, 0.5), transparent, rgba(0, 168, 232, 0.38), transparent);
	animation: aurora 18s ease-in-out infinite reverse;
}

.a3 {
	left: 35%;
	top: 28%;
	width: 36vw;
	height: 36vw;
	opacity: 0.2;
	background: conic-gradient(from 40deg, rgba(120, 220, 255, 0.35), transparent 40%, rgba(0, 168, 232, 0.28), transparent 75%);
	animation: aurora 20s ease-in-out infinite;
}

.bg-scan {
	position: absolute;
	inset: 0;
	background: linear-gradient(
		180deg,
		transparent 0%,
		rgba(0, 168, 232, 0.04) 46%,
		rgba(62, 198, 255, 0.12) 50%,
		rgba(0, 168, 232, 0.04) 54%,
		transparent 100%
	);
	background-size: 100% 240%;
	animation: scan 8s linear infinite;
	opacity: 0.4;
	z-index: 1;
}

.bg-canvas {
	position: absolute;
	inset: 0;
	width: 100%;
	height: 100%;
	opacity: 0.45;
	mask-image: radial-gradient(ellipse at 35% 45%, #000 20%, transparent 72%);
}

.bg-vignette {
	position: absolute;
	inset: 0;
	z-index: 1;
	background:
		radial-gradient(ellipse at center, transparent 38%, rgba(4, 10, 18, 0.62) 100%),
		linear-gradient(90deg, rgba(4, 10, 18, 0.2), transparent 22%, transparent 78%, rgba(4, 10, 18, 0.35));
}

.bg-spotlight {
	position: absolute;
	inset: 0;
	z-index: 1;
	background: radial-gradient(560px circle at var(--mx) var(--my), rgba(0, 168, 232, 0.16), transparent 46%);
	transition: background 0.08s linear;
}

.bg-glow {
	position: absolute;
	border-radius: 50%;
	filter: blur(90px);
}

.g1 {
	width: 540px;
	height: 540px;
	left: -150px;
	top: -130px;
	background: rgba(0, 168, 232, 0.42);
	animation: float-a 11s ease-in-out infinite;
}

.g2 {
	width: 480px;
	height: 480px;
	right: -110px;
	bottom: -150px;
	background: rgba(62, 198, 255, 0.26);
	animation: float-b 13s ease-in-out infinite;
}

.g3 {
	width: 260px;
	height: 260px;
	left: 42%;
	top: 18%;
	background: rgba(0, 168, 232, 0.14);
	animation: float-a 15s ease-in-out infinite reverse;
}

/* ===== Cosmic Planet Scene ===== */
.scene-3d {
	position: absolute;
	left: -2%;
	top: 4%;
	width: 64%;
	height: 92%;
	perspective: 900px;
	perspective-origin: 42% 48%;
	z-index: 0;
	transform-style: preserve-3d;
}

.scene-world {
	position: absolute;
	inset: 0;
	transform-style: preserve-3d;
	transform: rotateX(62deg) rotateZ(-12deg) translate3d(30px, -20px, 0);
	animation: galaxy-tilt 28s ease-in-out infinite;
}

.floor-grid {
	position: absolute;
	left: 50%;
	top: 50%;
	width: 980px;
	height: 980px;
	margin-left: -490px;
	margin-top: -490px;
	background-image:
		linear-gradient(rgba(0, 168, 232, 0.22) 1px, transparent 1px),
		linear-gradient(90deg, rgba(0, 168, 232, 0.22) 1px, transparent 1px);
	background-size: 44px 44px;
	transform: translateZ(0);
	mask-image: radial-gradient(circle at center, #000 12%, transparent 62%);
	animation: grid-flow 18s linear infinite;
}

.floor-glow {
	position: absolute;
	left: 50%;
	top: 50%;
	width: 360px;
	height: 360px;
	margin-left: -180px;
	margin-top: -180px;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(0, 168, 232, 0.4), transparent 70%);
	filter: blur(16px);
	transform: translateZ(6px);
	animation: core-breathe 5s ease-in-out infinite;
}

.orbit-track {
	position: absolute;
	left: 50%;
	top: 50%;
	border-radius: 50%;
	border: 1px solid rgba(122, 217, 255, 0.3);
	box-shadow:
		0 0 24px rgba(0, 168, 232, 0.12),
		inset 0 0 20px rgba(0, 168, 232, 0.06);
	transform: translateZ(40px) rotateX(72deg);

	&::after {
		content: '';
		position: absolute;
		top: 50%;
		left: 50%;
		width: 5px;
		height: 5px;
		margin: -2.5px 0 0 -2.5px;
		border-radius: 50%;
		background: #9ae6ff;
		box-shadow: 0 0 10px rgba(154, 230, 255, 0.95);
		animation: track-bead 10s linear infinite;
	}
}

.ot1 {
	--r: 110px;
	width: 220px;
	height: 220px;
	margin: -110px 0 0 -110px;
}

.ot2 {
	--r: 170px;
	width: 340px;
	height: 340px;
	margin: -170px 0 0 -170px;
	border-style: dashed;
	border-color: rgba(62, 198, 255, 0.3);
	opacity: 0.9;

	&::after {
		animation-duration: 16s;
		animation-direction: reverse;
	}
}

.ot3 {
	--r: 235px;
	width: 470px;
	height: 470px;
	margin: -235px 0 0 -235px;
	opacity: 0.5;
	border-color: rgba(0, 168, 232, 0.22);

	&::after {
		animation-duration: 22s;
		width: 4px;
		height: 4px;
		margin: -2px 0 0 -2px;
	}
}

.core-hub {
	position: absolute;
	left: 50%;
	top: 50%;
	width: 88px;
	height: 88px;
	margin: -44px 0 0 -44px;
	transform: translateZ(120px);
	transform-style: preserve-3d;
	display: flex;
	align-items: center;
	justify-content: center;
}

.hub-glow {
	position: absolute;
	inset: 4px;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(62, 198, 255, 0.5), transparent 70%);
	filter: blur(10px);
	animation: hub-pulse 3.2s ease-in-out infinite;
	transform: translateZ(-20px);
}

.hub-cube {
	position: relative;
	width: 20px;
	height: 20px;
	transform-style: preserve-3d;
	animation: hub-cube-spin 10s linear infinite;
	z-index: 2;
}

.hc {
	position: absolute;
	inset: 0;
	border-radius: 4px;
	border: 1px solid rgba(210, 245, 255, 0.5);
	background:
		linear-gradient(145deg, rgba(255, 255, 255, 0.45) 0%, transparent 42%),
		linear-gradient(180deg, rgba(154, 230, 255, 0.9), rgba(0, 168, 232, 0.78));
	box-shadow:
		inset 0 0 8px rgba(255, 255, 255, 0.22),
		0 0 12px rgba(0, 168, 232, 0.4);
	backface-visibility: hidden;

	&.f-front { transform: translateZ(10px); }
	&.f-back { transform: rotateY(180deg) translateZ(10px); }
	&.f-right { transform: rotateY(90deg) translateZ(10px); }
	&.f-left { transform: rotateY(-90deg) translateZ(10px); }
	&.f-top {
		transform: rotateX(90deg) translateZ(10px);
		background: linear-gradient(180deg, rgba(220, 248, 255, 0.95), rgba(100, 210, 255, 0.55));
	}
	&.f-bottom {
		transform: rotateX(-90deg) translateZ(10px);
		background: linear-gradient(180deg, rgba(0, 120, 170, 0.85), rgba(6, 50, 80, 0.95));
	}
}

.hub-ring {
	position: absolute;
	border-radius: 50%;
	border: 1.5px solid rgba(158, 230, 255, 0.35);
	transform-style: preserve-3d;

	&.r-a {
		inset: 10px;
		border-style: dashed;
		animation: hub-spin 12s linear infinite;
		transform: translateZ(8px);
	}

	&.r-b {
		inset: 0;
		border-color: rgba(0, 168, 232, 0.28);
		animation: hub-spin 18s linear infinite reverse;
		transform: rotateX(70deg) translateZ(0);
	}
}

.hub-scan {
	position: absolute;
	inset: -8px;
	border-radius: 50%;
	background: conic-gradient(from 0deg, transparent 0%, rgba(62, 198, 255, 0.45) 8%, transparent 22%);
	animation: hub-spin 5.5s linear infinite;
	mask-image: radial-gradient(circle, transparent 42%, #000 48%, #000 58%, transparent 64%);
	transform: translateZ(4px);
}

.tech-orbit {
	position: absolute;
	left: 50%;
	top: 50%;
	transform-style: preserve-3d;
	transform: translateZ(90px) rotateX(72deg);
}

.to1 {
	width: 220px;
	height: 220px;
	margin: -110px 0 0 -110px;
	animation: tech-orbit 14s linear infinite;
}

.to2 {
	width: 340px;
	height: 340px;
	margin: -170px 0 0 -170px;
	animation: tech-orbit 24s linear infinite reverse;
}

.to3 {
	width: 470px;
	height: 470px;
	margin: -235px 0 0 -235px;
	animation: tech-orbit 36s linear infinite;
}

.to4 {
	width: 560px;
	height: 560px;
	margin: -280px 0 0 -280px;
	animation: tech-orbit 48s linear infinite reverse;
}

.tech-item {
	position: absolute;
	top: 0;
	left: 50%;
	width: 36px;
	height: 36px;
	margin-left: -18px;
	margin-top: -18px;
	transform-style: preserve-3d;
	transform: rotateX(-72deg);
}

.mesh {
	position: absolute;
	left: 50%;
	top: 50%;
	transform-style: preserve-3d;
	transform: translate(-50%, -50%);
}

/* ===== 3D Chip (petite) ===== */
.chip-item {
	width: 36px;
	height: 36px;
	margin-left: -18px;
	margin-top: -18px;
}

.chip-3d {
	width: 22px;
	height: 22px;
	animation: chip-spin 14s linear infinite;

	.face {
		position: absolute;
		width: 22px;
		height: 22px;
		border-radius: 3px;
		border: 1px solid rgba(150, 225, 250, 0.5);
		background:
			linear-gradient(145deg, rgba(255, 255, 255, 0.16), transparent 40%),
			linear-gradient(160deg, #223848 0%, #122636 55%, #091620 100%);
		box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.16);
		backface-visibility: hidden;

		&.front {
			transform: translateZ(4px);
			overflow: hidden;
		}
		&.back { transform: rotateY(180deg) translateZ(4px); }
		&.right {
			width: 8px;
			left: 7px;
			transform: rotateY(90deg) translateZ(11px);
			background: linear-gradient(180deg, #1a3346, #0a1620);
			border-radius: 1px;
		}
		&.left {
			width: 8px;
			left: 7px;
			transform: rotateY(-90deg) translateZ(11px);
			background: linear-gradient(180deg, #1a3346, #0a1620);
			border-radius: 1px;
		}
		&.top {
			height: 8px;
			top: 7px;
			transform: rotateX(90deg) translateZ(11px);
			background: linear-gradient(90deg, #27485c, #142838);
			border-radius: 1px;
		}
		&.bottom {
			height: 8px;
			top: 7px;
			transform: rotateX(-90deg) translateZ(11px);
			background: #060e16;
			border-radius: 1px;
		}
	}

	.die {
		position: absolute;
		inset: 4px;
		border-radius: 2px;
		overflow: hidden;
		background: linear-gradient(160deg, #0c2434, #06141e);
		border: 1px solid rgba(62, 198, 255, 0.4);
		box-shadow: inset 0 0 6px rgba(0, 168, 232, 0.28);
	}

	.die-grid {
		position: absolute;
		inset: 0;
		opacity: 0.5;
		background-image:
			linear-gradient(rgba(62, 198, 255, 0.28) 1px, transparent 1px),
			linear-gradient(90deg, rgba(62, 198, 255, 0.28) 1px, transparent 1px);
		background-size: 3px 3px;
	}

	.die-core {
		position: absolute;
		left: 50%;
		top: 50%;
		width: 4px;
		height: 4px;
		margin: -2px 0 0 -2px;
		border-radius: 1px;
		background: radial-gradient(circle at 30% 30%, #fff, #3ec6ff 60%, #0088bb);
		box-shadow: 0 0 5px rgba(62, 198, 255, 0.9);
		animation: die-pulse 2.4s ease-in-out infinite;
	}

	.die-scan {
		position: absolute;
		left: 0;
		right: 0;
		height: 2px;
		background: linear-gradient(180deg, transparent, rgba(154, 230, 255, 0.45), transparent);
		animation: die-scan 2.6s linear infinite;
	}

	.mark {
		position: absolute;
		left: 2px;
		top: 2px;
		width: 2.5px;
		height: 2.5px;
		border-radius: 50%;
		background: radial-gradient(circle at 35% 35%, #c8f2ff, #0679a8);
		box-shadow: 0 0 3px rgba(62, 198, 255, 0.7);
		z-index: 2;
	}

	.pins {
		position: absolute;
		display: flex;
		transform-style: preserve-3d;
		z-index: 3;

		em {
			display: block;
			border-radius: 0.5px;
			background: linear-gradient(180deg, #e8f9ff, #3ec6ff 50%, #1a8fbf);
			box-shadow: 0 0 2px rgba(62, 198, 255, 0.7);
		}

		&.side-l,
		&.side-r {
			flex-direction: column;
			justify-content: space-between;
			height: 16px;
			top: 3px;
			width: 5px;

			em {
				width: 5px;
				height: 1.5px;
			}
		}
		&.side-l {
			left: -5px;
			transform: translateZ(1px);
		}
		&.side-r {
			right: -5px;
			transform: translateZ(1px);
		}
		&.side-t,
		&.side-b {
			flex-direction: row;
			justify-content: space-between;
			width: 16px;
			left: 3px;
			height: 5px;

			em {
				width: 1.5px;
				height: 5px;
			}
		}
		&.side-t {
			top: -5px;
			transform: translateZ(1px);
		}
		&.side-b {
			bottom: -5px;
			transform: translateZ(1px);
		}
	}
}

/* ===== 3D Server rack (refined) ===== */
.server-item {
	width: 30px;
	height: 36px;
	margin-left: -15px;
	margin-top: -18px;
}

.server-3d {
	width: 18px;
	height: 26px;
	animation: server-spin 18s linear infinite;

	.face {
		position: absolute;
		backface-visibility: hidden;
		border: 1px solid rgba(150, 220, 245, 0.4);

		&.front,
		&.back {
			width: 18px;
			height: 26px;
			border-radius: 2.5px;
			background:
				linear-gradient(145deg, rgba(255, 255, 255, 0.14), transparent 38%),
				linear-gradient(180deg, #243a4e 0%, #152838 52%, #0b1a26 100%);
			box-shadow:
				inset 0 1px 0 rgba(255, 255, 255, 0.14),
				inset 0 -1px 0 rgba(0, 0, 0, 0.25);
		}
		&.front {
			transform: translateZ(7px);
			overflow: hidden;
		}
		&.back {
			transform: rotateY(180deg) translateZ(7px);
			background: linear-gradient(180deg, #1a2e3e, #0a1620);
		}
		&.right,
		&.left {
			width: 14px;
			height: 26px;
			left: 2px;
			border-radius: 1.5px;
			background:
				linear-gradient(180deg, #1c3346 0%, #0e1e2c 100%),
				repeating-linear-gradient(180deg, transparent 0 3px, rgba(0, 168, 232, 0.06) 3px 4px);
		}
		&.right { transform: rotateY(90deg) translateZ(9px); }
		&.left { transform: rotateY(-90deg) translateZ(9px); }
		&.top,
		&.bottom {
			width: 18px;
			height: 14px;
			top: 6px;
			border-radius: 1.5px;
		}
		&.top {
			transform: rotateX(90deg) translateZ(13px);
			background:
				linear-gradient(145deg, rgba(255, 255, 255, 0.18), transparent 45%),
				linear-gradient(90deg, #2e4c64, #183246);
		}
		&.bottom {
			transform: rotateX(-90deg) translateZ(13px);
			background: #050c14;
		}
	}

	.bezel {
		position: absolute;
		inset: 1px 1px auto;
		height: 2px;
		border-radius: 1px 1px 0 0;
		background: linear-gradient(90deg, transparent, rgba(154, 230, 255, 0.35), transparent);
	}

	.bay {
		position: absolute;
		left: 2px;
		right: 6px;
		height: 3.5px;
		border-radius: 0.5px;
		background:
			linear-gradient(180deg, rgba(255, 255, 255, 0.04), transparent 40%),
			linear-gradient(180deg, #0a1620, #050c14);
		border: 1px solid rgba(62, 198, 255, 0.3);
		box-shadow:
			inset 0 0 3px rgba(0, 0, 0, 0.55),
			0 0 2px rgba(0, 168, 232, 0.08);

		i {
			position: absolute;
			left: 1px;
			top: 0.75px;
			bottom: 0.75px;
			width: 1.5px;
			border-radius: 0.5px;
			background: linear-gradient(180deg, #c8f4ff, #3ec6ff);
			box-shadow: 0 0 2px rgba(62, 198, 255, 0.5);
		}

		em {
			position: absolute;
			right: 1.5px;
			top: 50%;
			width: 4px;
			height: 1px;
			margin-top: -0.5px;
			border-radius: 0.5px;
			background: rgba(154, 230, 255, 0.45);
		}

		&.b1 { top: 3.5px; }
		&.b2 { top: 7.8px; }
		&.b3 { top: 12.1px; }
		&.b4 { top: 16.4px; }
	}

	.rail {
		position: absolute;
		left: 1px;
		top: 3px;
		bottom: 6px;
		width: 0.5px;
		background: linear-gradient(180deg, transparent, rgba(122, 217, 255, 0.35), transparent);
	}

	.pwr {
		position: absolute;
		right: 2px;
		bottom: 5.5px;
		width: 3px;
		height: 3px;
		border-radius: 50%;
		border: 1px solid rgba(154, 230, 255, 0.45);
		background: radial-gradient(circle at 35% 35%, rgba(122, 217, 255, 0.5), rgba(0, 80, 120, 0.6));
		box-shadow: 0 0 4px rgba(0, 168, 232, 0.35);
	}

	.led {
		position: absolute;
		right: 2.5px;
		width: 1.5px;
		height: 1.5px;
		border-radius: 50%;
		box-shadow: 0 0 3px currentColor;

		&.l1 {
			top: 4px;
			background: #5dff9a;
			color: #5dff9a;
			animation: led-blink 2.2s ease-in-out infinite;
		}
		&.l2 {
			top: 8.5px;
			background: #3ec6ff;
			color: #3ec6ff;
			animation: led-blink 1.6s ease-in-out infinite 0.35s;
		}
		&.l3 {
			top: 13px;
			background: #ffd56a;
			color: #ffd56a;
			animation: led-blink 2.8s ease-in-out infinite 0.7s;
		}
	}

	.vent {
		position: absolute;
		left: 2px;
		right: 6px;
		bottom: 1.5px;
		height: 2.5px;
		border-radius: 0.5px;
		background: repeating-linear-gradient(
			90deg,
			rgba(90, 200, 240, 0.45) 0 1px,
			rgba(8, 24, 36, 0.9) 1px 2.2px
		);
		border: 1px solid rgba(62, 198, 255, 0.2);
		opacity: 0.85;
	}

	.port {
		position: absolute;
		left: 50%;
		width: 5px;
		height: 2px;
		margin-left: -2.5px;
		border-radius: 0.5px;
		background: #061018;
		border: 1px solid rgba(62, 198, 255, 0.25);
		box-shadow: inset 0 0 2px rgba(0, 0, 0, 0.6);

		&.p1 { top: 5px; }
		&.p2 { top: 10px; width: 7px; margin-left: -3.5px; }
		&.p3 { top: 15px; }
	}

	.side-vent {
		position: absolute;
		left: 3px;
		right: 3px;
		top: 4px;
		bottom: 4px;
		background: repeating-linear-gradient(
			180deg,
			rgba(122, 217, 255, 0.28) 0 1px,
			transparent 1px 3px
		);
		opacity: 0.55;
		border-radius: 1px;
	}

	.top-logo {
		position: absolute;
		left: 50%;
		top: 50%;
		width: 5px;
		height: 5px;
		margin: -2.5px 0 0 -2.5px;
		border-radius: 1px;
		background:
			linear-gradient(145deg, rgba(255, 255, 255, 0.45), transparent 42%),
			linear-gradient(180deg, #7ad9ff, #00a8e8);
		box-shadow: 0 0 4px rgba(0, 168, 232, 0.55);
	}
}

/* ===== 3D Atom node ===== */
.atom-item {
	width: 32px;
	height: 32px;
	margin-left: -16px;
	margin-top: -16px;
}

.atom-3d {
	width: 26px;
	height: 26px;
	animation: mesh-spin 16s linear infinite;

	.atom-core {
		position: absolute;
		left: 50%;
		top: 50%;
		width: 7px;
		height: 7px;
		margin: -3.5px 0 0 -3.5px;
		border-radius: 50%;
		background:
			radial-gradient(circle at 32% 28%, #fff 0%, #7ad9ff 38%, #00a8e8 72%, #0679a8 100%);
		box-shadow:
			0 0 8px rgba(62, 198, 255, 0.95),
			0 0 16px rgba(0, 168, 232, 0.45);
		animation: die-pulse 2.2s ease-in-out infinite;
		z-index: 2;
	}

	.atom-glow {
		position: absolute;
		left: 50%;
		top: 50%;
		width: 16px;
		height: 16px;
		margin: -8px 0 0 -8px;
		border-radius: 50%;
		background: radial-gradient(circle, rgba(62, 198, 255, 0.35), transparent 70%);
		transform: translateZ(0);
	}

	.atom-ring {
		position: absolute;
		left: 50%;
		top: 50%;
		border: 1px solid rgba(154, 230, 255, 0.45);
		border-radius: 50%;
		transform-style: preserve-3d;
		box-shadow: 0 0 6px rgba(0, 168, 232, 0.15);

		em {
			position: absolute;
			top: -1.5px;
			left: 50%;
			width: 3px;
			height: 3px;
			margin-left: -1.5px;
			border-radius: 50%;
			background: radial-gradient(circle at 30% 30%, #fff, #3ec6ff);
			box-shadow: 0 0 5px rgba(154, 230, 255, 1);
		}

		&.r1 {
			width: 22px;
			height: 22px;
			margin: -11px 0 0 -11px;
			animation: atom-ring-1 4s linear infinite;
		}
		&.r2 {
			width: 22px;
			height: 22px;
			margin: -11px 0 0 -11px;
			border-color: rgba(122, 217, 255, 0.38);
			animation: atom-ring-2 5.5s linear infinite reverse;

			em {
				width: 2.5px;
				height: 2.5px;
				margin-left: -1.25px;
				top: -1.25px;
			}
		}
		&.r3 {
			width: 16px;
			height: 16px;
			margin: -8px 0 0 -8px;
			border-color: rgba(0, 168, 232, 0.4);
			border-style: dashed;
			animation: atom-ring-3 3.4s linear infinite;

			em {
				width: 2px;
				height: 2px;
				margin-left: -1px;
				top: -1px;
			}
		}
	}
}

/* ===== 3D Satellite (petite) ===== */
.sat-item {
	width: 44px;
	height: 28px;
	margin-left: -22px;
	margin-top: -14px;
}

.sat-3d {
	width: 40px;
	height: 16px;
	animation: mesh-spin-tilt 14s linear infinite reverse;

	.sat-body-3d {
		position: absolute;
		left: 50%;
		top: 50%;
		width: 10px;
		height: 10px;
		margin: -5px 0 0 -5px;
		transform-style: preserve-3d;

		.face {
			position: absolute;
			width: 10px;
			height: 10px;
			border-radius: 2px;
			border: 1px solid rgba(255, 255, 255, 0.3);
			background:
				linear-gradient(145deg, rgba(255, 255, 255, 0.45), transparent 42%),
				linear-gradient(180deg, #6fd4ff, #0090c8);
			box-shadow: 0 0 7px rgba(0, 168, 232, 0.4);
			backface-visibility: hidden;

			&.front {
				transform: translateZ(5px);
				i {
					position: absolute;
					inset: 2.5px;
					border-radius: 1px;
					background: rgba(255, 255, 255, 0.35);
				}
			}
			&.back { transform: rotateY(180deg) translateZ(5px); }
			&.right {
				transform: rotateY(90deg) translateZ(5px);
				background: linear-gradient(180deg, #3eb8e8, #0679a8);
			}
			&.left {
				transform: rotateY(-90deg) translateZ(5px);
				background: linear-gradient(180deg, #3eb8e8, #0679a8);
			}
			&.top {
				transform: rotateX(90deg) translateZ(5px);
				background: linear-gradient(180deg, #b0ecff, #3ec6ff);
			}
			&.bottom {
				transform: rotateX(-90deg) translateZ(5px);
				background: #04688f;
			}
		}
	}

	.sat-boom {
		position: absolute;
		top: 50%;
		width: 5px;
		height: 1px;
		margin-top: -0.5px;
		background: rgba(154, 230, 255, 0.7);
		transform: translateZ(1px);

		&.left { left: 9px; }
		&.right { right: 9px; }
	}

	.sat-panel {
		position: absolute;
		top: 50%;
		width: 12px;
		height: 8px;
		margin-top: -4px;
		border-radius: 1px;
		display: flex;
		gap: 1px;
		padding: 1px;
		background: rgba(0, 80, 120, 0.55);
		border: 1px solid rgba(158, 230, 255, 0.45);
		box-shadow: 0 0 6px rgba(62, 198, 255, 0.28);
		transform-style: preserve-3d;

		i {
			flex: 1;
			border-radius: 0.5px;
			background: linear-gradient(180deg, rgba(154, 230, 255, 0.85), rgba(0, 120, 170, 0.75));
			box-shadow: inset 0 0 2px rgba(255, 255, 255, 0.25);
		}

		&.left {
			left: 0;
			transform: translateZ(1px) rotateY(22deg);
			transform-origin: right center;
		}
		&.right {
			right: 0;
			transform: translateZ(1px) rotateY(-22deg);
			transform-origin: left center;
		}
	}

	.sat-antenna {
		position: absolute;
		left: 50%;
		top: -6px;
		width: 1.5px;
		height: 7px;
		margin-left: -0.75px;
		border-radius: 999px;
		background: linear-gradient(180deg, #fff, #3ec6ff);
		box-shadow: 0 0 5px rgba(62, 198, 255, 0.75);
		transform: translateZ(6px);

		&::after {
			content: '';
			position: absolute;
			top: -2.5px;
			left: 50%;
			width: 3.5px;
			height: 3.5px;
			margin-left: -1.75px;
			border-radius: 50%;
			background: #c8f4ff;
			box-shadow: 0 0 5px rgba(154, 230, 255, 1);
		}
	}
}

.signal {
	position: absolute;
	width: 3px;
	height: 3px;
	border-radius: 1px;
	background: linear-gradient(135deg, #fff, #3ec6ff);
	box-shadow: 0 0 8px rgba(62, 198, 255, 0.9);
	animation: signal-drift 14s ease-in-out infinite;
}

.sg1 { left: 18%; top: 22%; animation-delay: 0s; }
.sg2 { left: 28%; top: 58%; animation-delay: 1.5s; }
.sg3 { left: 42%; top: 16%; animation-delay: 3s; }
.sg4 { left: 55%; top: 68%; animation-delay: 4.2s; }
.sg5 { left: 66%; top: 30%; animation-delay: 2.1s; }
.sg6 { left: 74%; top: 52%; animation-delay: 5s; }

.meteor {
	position: absolute;
	width: 90px;
	height: 2px;
	border-radius: 999px;
	background: linear-gradient(90deg, transparent, rgba(62, 198, 255, 0.9), transparent);
	opacity: 0;
	transform: rotate(-32deg);
	animation: meteor 7s linear infinite;
	z-index: 1;
}

.m1 { top: 12%; left: 55%; animation-delay: 0.2s; }
.m2 { top: 22%; left: 72%; animation-delay: 1.4s; }
.m3 { top: 34%; left: 48%; animation-delay: 2.6s; }
.m4 { top: 18%; left: 82%; animation-delay: 3.5s; }
.m5 { top: 46%; left: 66%; animation-delay: 4.2s; }
.m6 { top: 28%; left: 38%; animation-delay: 5.1s; }
.m7 { top: 58%; left: 78%; animation-delay: 1.1s; }
.m8 { top: 64%; left: 52%; animation-delay: 2.2s; }

.login-topbar {
	position: relative;
	z-index: 2;
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 16px 36px;
	backdrop-filter: blur(14px);
	background: linear-gradient(180deg, rgba(5, 12, 22, 0.55), rgba(5, 12, 22, 0.08));
	border-bottom: 1px solid rgba(62, 198, 255, 0.08);
	box-shadow: 0 1px 0 rgba(255, 255, 255, 0.03) inset;
}

.topbar-brand {
	display: flex;
	align-items: center;
	gap: 12px;
}

.topbar-logo {
	width: 36px;
	height: 36px;
	border-radius: 10px;
	box-shadow:
		0 8px 22px rgba(0, 168, 232, 0.32),
		0 0 0 1px rgba(154, 230, 255, 0.2);
	animation: logo-float 4.5s ease-in-out infinite;
}

.topbar-text {
	display: flex;
	flex-direction: column;
	line-height: 1.2;
}

.topbar-name {
	font-size: 16px;
	font-weight: 700;
	letter-spacing: 2.5px;
	background: linear-gradient(120deg, #fff 20%, #9ae6ff 80%);
	-webkit-background-clip: text;
	background-clip: text;
	color: transparent;
}

.topbar-sub {
	margin-top: 2px;
	font-size: 11px;
	letter-spacing: 1.2px;
	color: rgba(255, 255, 255, 0.42);
}

.topbar-meta {
	display: flex;
	align-items: center;
	gap: 10px;
}

.topbar-chip,
.topbar-tag {
	font-size: 12px;
	letter-spacing: 0.8px;
	padding: 7px 12px;
	border-radius: 999px;
	border: 1px solid rgba(255, 255, 255, 0.1);
	background: rgba(255, 255, 255, 0.045);
	color: rgba(255, 255, 255, 0.62);
	backdrop-filter: blur(8px);
}

.topbar-chip {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	border-color: rgba(0, 168, 232, 0.32);
	background: rgba(0, 168, 232, 0.12);
	color: #b7e9ff;
}

.chip-live {
	width: 7px;
	height: 7px;
	border-radius: 50%;
	background: #3ec6ff;
	box-shadow: 0 0 0 0 rgba(62, 198, 255, 0.55);
	animation: pulse 1.8s ease-out infinite;
}

.login-main {
	position: relative;
	z-index: 2;
	min-height: calc(100vh - 78px);
	display: grid;
	grid-template-columns: 1.12fr 0.88fr;
	align-items: center;
	gap: 28px;
	padding: 8px 48px 40px;
}

.brand-pane-inner {
	max-width: 580px;
	animation: rise-in 0.7s ease both;
	transition: transform 0.25s ease-out;
	will-change: transform;
}

.brand-eyebrow {
	margin: 0 0 18px;
	display: inline-flex;
	align-items: center;
	gap: 10px;
	padding: 7px 16px 7px 8px;
	border-radius: 999px;
	font-size: 12.5px;
	letter-spacing: 1.4px;
	color: #c8f0ff;
	background:
		linear-gradient(135deg, rgba(255, 255, 255, 0.08), transparent 42%),
		linear-gradient(135deg, rgba(0, 168, 232, 0.22), rgba(62, 198, 255, 0.08));
	border: 1px solid rgba(122, 217, 255, 0.35);
	box-shadow:
		0 10px 28px rgba(0, 168, 232, 0.16),
		inset 0 1px 0 rgba(255, 255, 255, 0.14),
		0 0 0 1px rgba(0, 168, 232, 0.06);
	backdrop-filter: blur(12px);
}

.eyebrow-mark {
	position: relative;
	width: 22px;
	height: 22px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
}

.eyebrow-dot {
	width: 8px;
	height: 8px;
	border-radius: 50%;
	background: radial-gradient(circle at 35% 30%, #fff, #3ec6ff 55%, #0088bb);
	box-shadow: 0 0 10px rgba(62, 198, 255, 0.85);
	animation: pulse 2s ease-out infinite;
	z-index: 1;
}

.eyebrow-ring {
	position: absolute;
	inset: 0;
	border-radius: 50%;
	border: 1px solid rgba(154, 230, 255, 0.45);
	animation: pulse-ring 2.4s ease-out infinite;
}

.eyebrow-text {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	font-weight: 600;

	em {
		font-style: normal;
		color: #9ae6ff;
		font-weight: 800;
		letter-spacing: 1.8px;
	}
}

.eyebrow-sep {
	opacity: 0.45;
	font-weight: 400;
}

.brand-hero {
	margin: 0;
	font-size: clamp(58px, 7.2vw, 92px);
	line-height: 0.92;
	letter-spacing: 4px;
	font-weight: 800;
	color: #fff;
	text-shadow: 0 12px 40px rgba(0, 168, 232, 0.25);
	filter: drop-shadow(0 0 28px rgba(0, 168, 232, 0.18));
}

.hero-text {
	display: inline-block;
	animation: hero-in 0.8s cubic-bezier(0.22, 1, 0.36, 1) both;
	text-shadow:
		0 0 40px rgba(154, 230, 255, 0.2),
		0 8px 24px rgba(0, 0, 0, 0.35);
}

.hero-accent {
	display: inline-block;
	background: linear-gradient(120deg, #9ae6ff, #3ec6ff, #00a8e8, #9ae6ff);
	background-size: 220% auto;
	-webkit-background-clip: text;
	background-clip: text;
	color: transparent;
	animation:
		hero-in 0.9s cubic-bezier(0.22, 1, 0.36, 1) 0.08s both,
		shine-text 4.5s linear infinite;
}

.brand-slogan {
	margin: 18px 0 10px;
	font-size: 18px;
	font-weight: 600;
	letter-spacing: 2px;
	color: rgba(255, 255, 255, 0.88);
}

.slogan-ch {
	display: inline-block;
	opacity: 0;
	transform: translateY(8px);
	animation: char-in 0.45s ease forwards;
	white-space: pre;
}

.slogan-caret {
	display: inline-block;
	width: 2px;
	height: 1em;
	margin-left: 4px;
	vertical-align: -2px;
	background: #3ec6ff;
	box-shadow: 0 0 10px rgba(62, 198, 255, 0.8);
	animation: caret-blink 1s steps(1) infinite;
}

.brand-lead {
	margin: 0 0 26px;
	max-width: 500px;
	font-size: 14px;
	line-height: 1.85;
	color: rgba(255, 255, 255, 0.6);
}

.brand-points {
	list-style: none;
	margin: 0;
	padding: 0;
	display: grid;
	grid-template-columns: repeat(2, minmax(0, 1fr));
	gap: 12px;

	li {
		--plate: #00a8e8;
		--plate-2: #3ec6ff;
		position: relative;
		display: flex;
		align-items: flex-start;
		gap: 13px;
		padding: 15px 14px 15px 13px;
		border-radius: 18px;
		background:
			linear-gradient(145deg, rgba(255, 255, 255, 0.07), transparent 38%),
			linear-gradient(165deg, rgba(12, 28, 44, 0.55), rgba(8, 18, 30, 0.35));
		border: 1px solid rgba(154, 230, 255, 0.16);
		backdrop-filter: blur(16px);
		animation: rise-in 0.6s ease both;
		overflow: hidden;
		box-shadow:
			inset 0 1px 0 rgba(255, 255, 255, 0.08),
			0 10px 24px rgba(0, 0, 0, 0.14);
		transition: transform 0.22s ease, border-color 0.22s ease, box-shadow 0.22s ease, background 0.22s ease;

		&::before {
			content: '';
			position: absolute;
			inset: 0 auto 0 0;
			width: 2px;
			background: linear-gradient(180deg, transparent, var(--plate-2), transparent);
			opacity: 0.7;
		}

		&::after {
			content: '';
			position: absolute;
			right: -20px;
			top: -20px;
			width: 80px;
			height: 80px;
			border-radius: 50%;
			background: radial-gradient(circle, color-mix(in srgb, var(--plate) 28%, transparent), transparent 70%);
			pointer-events: none;
		}

		&.tone-secure {
			--plate: #00a8e8;
			--plate-2: #5dff9a;
		}
		&.tone-speed {
			--plate: #00a8e8;
			--plate-2: #7ad9ff;
		}
		&.tone-scale {
			--plate: #3ec6ff;
			--plate-2: #9ae6ff;
		}
		&.tone-local {
			--plate: #0679a8;
			--plate-2: #3ec6ff;
		}

		&:hover {
			transform: translateY(-3px);
			border-color: color-mix(in srgb, var(--plate-2) 55%, transparent);
			background:
				linear-gradient(145deg, color-mix(in srgb, var(--plate) 18%, transparent), transparent 45%),
				linear-gradient(165deg, rgba(0, 168, 232, 0.16), rgba(8, 18, 30, 0.4));
			box-shadow:
				0 16px 32px rgba(0, 0, 0, 0.22),
				0 0 28px color-mix(in srgb, var(--plate) 22%, transparent),
				inset 0 1px 0 rgba(255, 255, 255, 0.1);

			.plate-ring {
				transform: scale(1.08);
				border-color: color-mix(in srgb, var(--plate-2) 70%, transparent);
			}

			.plate-core {
				transform: translate(-50%, -50%) scale(1.05);
			}
		}
	}

	.point-plate {
		position: relative;
		width: 44px;
		height: 44px;
		flex-shrink: 0;
		border-radius: 14px;
		background:
			linear-gradient(145deg, rgba(255, 255, 255, 0.16), transparent 42%),
			linear-gradient(160deg, color-mix(in srgb, var(--plate) 55%, #0a1a28), color-mix(in srgb, var(--plate-2) 35%, #07141e));
		border: 1px solid color-mix(in srgb, var(--plate-2) 45%, transparent);
		box-shadow:
			0 8px 18px color-mix(in srgb, var(--plate) 28%, transparent),
			inset 0 1px 0 rgba(255, 255, 255, 0.28);
	}

	.plate-glow {
		position: absolute;
		inset: 4px;
		border-radius: 10px;
		background: radial-gradient(circle at 30% 25%, rgba(255, 255, 255, 0.35), transparent 60%);
		pointer-events: none;
	}

	.plate-ring {
		position: absolute;
		inset: 3px;
		border-radius: 11px;
		border: 1px dashed color-mix(in srgb, var(--plate-2) 40%, transparent);
		transition: transform 0.25s ease, border-color 0.25s ease;
	}

	.plate-core {
		position: absolute;
		left: 50%;
		top: 46%;
		transform: translate(-50%, -50%);
		font-size: 15px;
		font-weight: 800;
		letter-spacing: 0.5px;
		color: #fff;
		text-shadow: 0 0 12px color-mix(in srgb, var(--plate-2) 70%, transparent);
		transition: transform 0.25s ease;
	}

	.plate-tag {
		position: absolute;
		right: -4px;
		bottom: -4px;
		min-width: 18px;
		height: 14px;
		padding: 0 4px;
		border-radius: 6px;
		display: inline-flex;
		align-items: center;
		justify-content: center;
		font-size: 9px;
		font-weight: 700;
		letter-spacing: 0.4px;
		color: #083044;
		background: linear-gradient(135deg, #c8f4ff, #3ec6ff);
		box-shadow: 0 2px 8px rgba(0, 168, 232, 0.35);
		border: 1px solid rgba(255, 255, 255, 0.35);
	}

	.point-body {
		min-width: 0;
		padding-top: 1px;
	}

	strong {
		display: block;
		font-size: 14px;
		margin-bottom: 4px;
		letter-spacing: 0.4px;
		color: #f2faff;
		text-shadow: 0 0 16px rgba(62, 198, 255, 0.2);
	}

	p {
		margin: 0;
		font-size: 12px;
		line-height: 1.55;
		color: rgba(200, 230, 245, 0.58);
	}
}

.hud-bar {
	margin-top: 22px;
	display: grid;
	grid-template-columns: repeat(3, minmax(0, 1fr));
	gap: 10px;
}

.hud-item {
	padding: 11px 12px;
	border-radius: 12px;
	background:
		linear-gradient(145deg, rgba(255, 255, 255, 0.05), transparent 40%),
		linear-gradient(160deg, rgba(0, 168, 232, 0.14), rgba(255, 255, 255, 0.03));
	border: 1px solid rgba(62, 198, 255, 0.22);
	backdrop-filter: blur(12px);
	box-shadow:
		inset 0 0 20px rgba(0, 168, 232, 0.05),
		0 8px 18px rgba(0, 0, 0, 0.12);
}

.hud-label {
	display: block;
	font-size: 10px;
	letter-spacing: 1.5px;
	color: rgba(183, 233, 255, 0.72);
}

.hud-value {
	display: block;
	margin-top: 4px;
	font-size: 13px;
	font-weight: 700;
	letter-spacing: 0.5px;
	color: #e8f8ff;
	text-shadow: 0 0 12px rgba(62, 198, 255, 0.35);
}

.hud-line {
	display: block;
	margin-top: 8px;
	height: 3px;
	border-radius: 999px;
	background: rgba(255, 255, 255, 0.08);
	overflow: hidden;

	i {
		display: block;
		height: 100%;
		border-radius: inherit;
		background: linear-gradient(90deg, #00a8e8, #9ae6ff, #3ec6ff);
		background-size: 200% 100%;
		box-shadow: 0 0 10px rgba(0, 168, 232, 0.6);
		animation: hud-flow 2.8s linear infinite;
	}
}

.form-pane {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	animation: rise-in 0.75s ease 0.08s both;
	transition: transform 0.25s ease-out;
	will-change: transform;
}

.login-card {
	width: min(520px, 100%);
	position: relative;
	overflow: hidden;
	display: flex;
	flex-direction: column;
	background:
		radial-gradient(circle at top right, rgba(0, 168, 232, 0.1), transparent 36%),
		radial-gradient(circle at 12% 88%, rgba(62, 198, 255, 0.05), transparent 30%),
		linear-gradient(180deg, #ffffff 0%, #f5fafd 55%, #eef6fb 100%);
	border-radius: 26px;
	padding: 0;
	color: #0f1724;
	border: 1px solid rgba(255, 255, 255, 0.7);
	backdrop-filter: blur(18px);
	box-shadow:
		0 36px 90px rgba(0, 0, 0, 0.38),
		0 0 0 1px rgba(0, 168, 232, 0.1),
		0 0 60px rgba(0, 168, 232, 0.1),
		inset 0 1px 0 rgba(255, 255, 255, 0.95);
	transition: box-shadow 0.25s ease, transform 0.25s ease;

	&:hover {
		box-shadow:
			0 44px 110px rgba(0, 0, 0, 0.44),
			0 0 0 1px rgba(0, 168, 232, 0.22),
			0 0 70px rgba(0, 168, 232, 0.18);
	}
}

.card-corner {
	position: absolute;
	width: 14px;
	height: 14px;
	z-index: 2;
	pointer-events: none;
	border-color: rgba(0, 168, 232, 0.45);
	border-style: solid;
	opacity: 0.7;

	&.c-tl {
		top: 10px;
		left: 10px;
		border-width: 1.5px 0 0 1.5px;
		border-radius: 2px 0 0 0;
	}
	&.c-tr {
		top: 10px;
		right: 10px;
		border-width: 1.5px 1.5px 0 0;
		border-radius: 0 2px 0 0;
	}
	&.c-bl {
		bottom: 10px;
		left: 10px;
		border-width: 0 0 1.5px 1.5px;
		border-radius: 0 0 0 2px;
	}
	&.c-br {
		bottom: 10px;
		right: 10px;
		border-width: 0 1.5px 1.5px 0;
		border-radius: 0 0 2px 0;
	}
}

.card-noise {
	position: absolute;
	inset: 0;
	pointer-events: none;
	opacity: 0.025;
	background-image: radial-gradient(rgba(15, 23, 36, 0.9) 0.55px, transparent 0.55px);
	background-size: 3px 3px;
	z-index: 0;
}

.card-accent {
	height: 3px;
	background: linear-gradient(90deg, #0679a8, #00a8e8, #9ae6ff, #3ec6ff, #00a8e8, #0679a8);
	background-size: 220% 100%;
	animation: accent-slide 3.6s linear infinite;
	flex-shrink: 0;
	box-shadow: 0 0 12px rgba(0, 168, 232, 0.45);
}

.card-glow {
	position: absolute;
	top: -80px;
	right: -60px;
	width: 220px;
	height: 220px;
	border-radius: 50%;
	background: rgba(0, 168, 232, 0.12);
	filter: blur(40px);
	pointer-events: none;
}

.card-shine {
	position: absolute;
	inset: 0;
	pointer-events: none;
	transition: background 0.08s linear;
	z-index: 0;
}

.card-ring {
	position: absolute;
	inset: -1px;
	border-radius: 26px;
	pointer-events: none;
	background: linear-gradient(135deg, rgba(0, 168, 232, 0.35), transparent 35%, transparent 65%, rgba(62, 198, 255, 0.25));
	mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
	mask-composite: exclude;
	padding: 1px;
	opacity: 0.55;
	animation: ring-glow 3.5s ease-in-out infinite;
}

.card-head {
	position: relative;
	z-index: 1;
	display: flex;
	align-items: center;
	gap: 14px;
	padding: 26px 30px 14px;
}

.card-logo-wrap {
	position: relative;
	width: 52px;
	height: 52px;
	border-radius: 15px;
	display: flex;
	align-items: center;
	justify-content: center;
	background: linear-gradient(145deg, #eaf7fd, #ffffff);
	border: 1px solid rgba(0, 168, 232, 0.16);
	box-shadow: 0 8px 20px rgba(0, 168, 232, 0.14);
}

.logo-pulse {
	position: absolute;
	inset: -4px;
	border-radius: 18px;
	border: 1px solid rgba(0, 168, 232, 0.35);
	animation: pulse-ring 2.4s ease-out infinite;
}

.card-logo {
	width: 36px;
	height: 36px;
	border-radius: 10px;
	position: relative;
	z-index: 1;
}

.card-head-text {
	min-width: 0;
	flex: 1;
}

.card-title-row {
	display: flex;
	align-items: center;
	gap: 10px;
	margin-bottom: 5px;

	h2 {
		margin: 0;
		font-size: 21px;
		font-weight: 700;
		color: #111827;
		letter-spacing: 0.2px;
	}
}

.card-badge {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 3px 9px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 600;
	letter-spacing: 0.4px;
	color: #0090c8;
	background: rgba(0, 168, 232, 0.1);
	border: 1px solid rgba(0, 168, 232, 0.16);
}

.badge-dot {
	width: 6px;
	height: 6px;
	border-radius: 50%;
	background: #11c26d;
	box-shadow: 0 0 0 0 rgba(17, 194, 109, 0.45);
	animation: pulse 1.8s ease-out infinite;
}

.card-head-text p {
	margin: 0;
	font-size: 13px;
	color: #7b8794;
	letter-spacing: 0.1px;
}

.login-tabs {
	position: relative;
	z-index: 1;
	display: flex;
	margin: 0 30px 4px;
	padding: 4px;
	border-radius: 14px;
	background:
		linear-gradient(180deg, rgba(0, 168, 232, 0.04), transparent),
		linear-gradient(180deg, #e8f1f8, #f2f7fb);
	border: 1px solid rgba(0, 168, 232, 0.08);
	box-shadow: inset 0 1px 2px rgba(15, 23, 36, 0.03);
}

.tab-btn {
	flex: 1;
	position: relative;
	z-index: 1;
	border: none;
	background: transparent;
	padding: 11px 10px;
	border-radius: 11px;
	font-size: 13.5px;
	font-weight: 600;
	color: #8b93a7;
	cursor: pointer;
	transition: color 0.2s ease;

	&.active {
		color: #0088c2;
	}
}

.tab-indicator {
	position: absolute;
	top: 4px;
	left: 4px;
	width: calc(50% - 4px);
	height: calc(100% - 8px);
	border-radius: 11px;
	background: linear-gradient(180deg, #ffffff, #f7fbfe);
	box-shadow:
		0 6px 16px rgba(15, 23, 36, 0.08),
		0 0 0 1px rgba(0, 168, 232, 0.1),
		0 0 18px rgba(0, 168, 232, 0.06);
	transition: left 0.3s cubic-bezier(0.22, 1, 0.36, 1);

	&.mobile {
		left: 50%;
	}
}

.card-body {
	position: relative;
	z-index: 1;
	padding: 14px 30px 4px;
	min-height: 244px;
	animation: form-fade 0.28s ease;
}

.card-agree {
	position: relative;
	z-index: 1;
	padding: 0 30px 2px;
}

.card-foot {
	position: relative;
	z-index: 1;
	padding: 2px 30px 20px;
}

.card-secure {
	margin-top: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-wrap: wrap;
	gap: 8px;
	padding: 10px 12px;
	border-radius: 12px;
	background:
		linear-gradient(135deg, rgba(0, 168, 232, 0.04), transparent 40%),
		linear-gradient(180deg, #f6fafd, #eef6fb);
	border: 1px solid rgba(0, 168, 232, 0.1);
	color: #667585;
	font-size: 12px;
	letter-spacing: 0.2px;
	box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.8);
}

.secure-dot {
	width: 7px;
	height: 7px;
	border-radius: 50%;
	background: #11c26d;
	box-shadow: 0 0 0 4px rgba(17, 194, 109, 0.14);
	animation: pulse 2.4s ease-out infinite;
}

.secure-sep {
	width: 3px;
	height: 3px;
	border-radius: 50%;
	background: #c5d3de;
}

.login-footnote {
	margin: 16px 0 0;
	font-size: 12px;
	color: rgba(183, 233, 255, 0.42);
	text-align: center;
	letter-spacing: 0.3px;
	text-shadow: 0 1px 8px rgba(0, 0, 0, 0.25);
}

@keyframes stars-twinkle {
	0%,
	100% {
		opacity: 0.4;
	}
	50% {
		opacity: 0.7;
	}
}

@keyframes hud-flow {
	to {
		background-position: 200% center;
	}
}

@keyframes rise-in {
	from {
		opacity: 0;
		transform: translateY(18px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

@keyframes form-fade {
	from {
		opacity: 0;
		transform: translateY(6px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

@keyframes float-a {
	0%,
	100% {
		transform: translate(0, 0);
	}
	50% {
		transform: translate(22px, 16px);
	}
}

@keyframes float-b {
	0%,
	100% {
		transform: translate(0, 0);
	}
	50% {
		transform: translate(-18px, -12px);
	}
}

@keyframes spin {
	to {
		transform: rotate(360deg);
	}
}

@keyframes mesh-drift {
	to {
		background-position: 56px 56px;
	}
}

@keyframes accent-slide {
	to {
		background-position: 200% 0;
	}
}

@keyframes dash {
	to {
		stroke-dashoffset: -180;
	}
}

@keyframes pulse {
	0% {
		box-shadow: 0 0 0 0 rgba(62, 198, 255, 0.55);
	}
	70% {
		box-shadow: 0 0 0 10px rgba(62, 198, 255, 0);
	}
	100% {
		box-shadow: 0 0 0 0 rgba(62, 198, 255, 0);
	}
}

@keyframes pulse-ring {
	0% {
		transform: scale(0.92);
		opacity: 0.8;
	}
	70% {
		transform: scale(1.12);
		opacity: 0;
	}
	100% {
		transform: scale(0.92);
		opacity: 0;
	}
}

@keyframes twinkle {
	0%,
	100% {
		opacity: 0.2;
		transform: scale(0.8);
	}
	50% {
		opacity: 0.8;
		transform: scale(1.15);
	}
}

@keyframes aurora {
	0%,
	100% {
		transform: translate(0, 0) rotate(0deg) scale(1);
	}
	50% {
		transform: translate(30px, -20px) rotate(18deg) scale(1.06);
	}
}

@keyframes scan {
	0% {
		background-position: 0 -40%;
	}
	100% {
		background-position: 0 140%;
	}
}

@keyframes track-bead {
	from {
		transform: rotate(0deg) translateY(calc(var(--r, 110px) * -1));
	}
	to {
		transform: rotate(360deg) translateY(calc(var(--r, 110px) * -1));
	}
}

@keyframes galaxy-tilt {
	0%,
	100% {
		transform: rotateX(62deg) rotateZ(-12deg) translate3d(30px, -20px, 0);
	}
	50% {
		transform: rotateX(58deg) rotateZ(-6deg) translate3d(42px, -8px, 0);
	}
}

@keyframes grid-flow {
	to {
		background-position: 44px 44px;
	}
}

@keyframes core-breathe {
	0%,
	100% {
		opacity: 0.7;
		transform: translateZ(6px) scale(1);
	}
	50% {
		opacity: 1;
		transform: translateZ(6px) scale(1.14);
	}
}

@keyframes hub-spin {
	to {
		transform: rotate(360deg);
	}
}

@keyframes hub-pulse {
	0%,
	100% {
		transform: scale(1);
		filter: brightness(1);
	}
	50% {
		transform: scale(1.08);
		filter: brightness(1.15);
	}
}

@keyframes tech-orbit {
	to {
		transform: translateZ(90px) rotateX(72deg) rotateZ(360deg);
	}
}

@keyframes mesh-spin {
	to {
		transform: translate(-50%, -50%) rotateY(360deg) rotateX(360deg);
	}
}

@keyframes mesh-spin-tilt {
	to {
		transform: translate(-50%, -50%) rotateY(-360deg) rotateZ(360deg);
	}
}

@keyframes chip-spin {
	0% {
		transform: translate(-50%, -50%) rotateY(0deg) rotateX(12deg);
	}
	100% {
		transform: translate(-50%, -50%) rotateY(360deg) rotateX(372deg);
	}
}

@keyframes server-spin {
	0% {
		transform: translate(-50%, -50%) rotateY(0deg) rotateX(8deg);
	}
	100% {
		transform: translate(-50%, -50%) rotateY(360deg) rotateX(368deg);
	}
}

@keyframes led-blink {
	0%,
	100% {
		opacity: 0.45;
		filter: brightness(0.85);
	}
	50% {
		opacity: 1;
		filter: brightness(1.35);
	}
}

@keyframes die-pulse {
	0%,
	100% {
		box-shadow: 0 0 6px rgba(62, 198, 255, 0.7);
		filter: brightness(1);
	}
	50% {
		box-shadow: 0 0 12px rgba(122, 217, 255, 1);
		filter: brightness(1.25);
	}
}

@keyframes die-scan {
	0% {
		top: -4px;
		opacity: 0;
	}
	15% {
		opacity: 0.9;
	}
	100% {
		top: 100%;
		opacity: 0;
	}
}

@keyframes hub-cube-spin {
	to {
		transform: rotateX(360deg) rotateY(360deg);
	}
}

@keyframes atom-ring-1 {
	from {
		transform: rotateX(68deg) rotateZ(0deg);
	}
	to {
		transform: rotateX(68deg) rotateZ(360deg);
	}
}

@keyframes atom-ring-2 {
	from {
		transform: rotateY(70deg) rotateZ(40deg);
	}
	to {
		transform: rotateY(70deg) rotateZ(400deg);
	}
}

@keyframes atom-ring-3 {
	from {
		transform: rotateX(-55deg) rotateZ(25deg);
	}
	to {
		transform: rotateX(-55deg) rotateZ(385deg);
	}
}

@keyframes signal-drift {
	0%,
	100% {
		opacity: 0.35;
		transform: translate3d(0, 0, 40px) scale(0.85);
	}
	50% {
		opacity: 1;
		transform: translate3d(12px, -18px, 80px) scale(1.25);
	}
}

@keyframes meteor {
	0% {
		opacity: 0;
		transform: translateX(0) translateY(0) rotate(-32deg);
	}
	8% {
		opacity: 1;
	}
	30% {
		opacity: 0;
		transform: translateX(220px) translateY(140px) rotate(-32deg);
	}
	100% {
		opacity: 0;
		transform: translateX(220px) translateY(140px) rotate(-32deg);
	}
}

@keyframes logo-float {
	0%,
	100% {
		transform: translateY(0);
	}
	50% {
		transform: translateY(-3px);
	}
}

@keyframes hero-in {
	from {
		opacity: 0;
		transform: translateY(24px) scale(0.96);
		filter: blur(6px);
	}
	to {
		opacity: 1;
		transform: translateY(0) scale(1);
		filter: blur(0);
	}
}

@keyframes shine-text {
	to {
		background-position: 220% center;
	}
}

@keyframes char-in {
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

@keyframes caret-blink {
	0%,
	45% {
		opacity: 1;
	}
	50%,
	100% {
		opacity: 0;
	}
}

@keyframes ring-glow {
	0%,
	100% {
		opacity: 0.35;
	}
	50% {
		opacity: 0.75;
	}
}

@media (max-width: 1100px) {
	.login-main {
		grid-template-columns: 1fr;
		padding: 8px 28px 36px;
	}

	.brand-pane,
	.scene-3d,
	.meteor {
		display: none;
	}

	.form-pane {
		min-height: calc(100vh - 110px);
	}

}

@media (max-width: 576px) {
	.login-topbar {
		padding: 16px 18px;
	}

	.login-main {
		padding: 0 14px 24px;
	}

	.login-card {
		border-radius: 20px;
	}

	.card-head,
	.card-body,
	.card-foot,
	.card-agree {
		padding-left: 18px;
		padding-right: 18px;
	}

	.login-tabs {
		margin-left: 18px;
		margin-right: 18px;
	}

	.topbar-meta {
		display: none;
	}
}

@media (prefers-reduced-motion: reduce) {
	*,
	*::before,
	*::after {
		animation: none !important;
		transition: none !important;
	}

	.bg-canvas,
	.bg-scan,
	.meteor,
	.scene-3d {
		display: none !important;
	}
}
</style>
