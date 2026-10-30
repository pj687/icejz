<template>
	<div v-if="appStore.sidebarOpened" class="sidebar-logo">
		<div class="logo-mark">
			<img class="logo-img" src="/logo.png" alt="ICEJZ" />
			<span class="logo-shine" aria-hidden="true"></span>
		</div>
		<div class="logo-text-wrap">
			<span class="logo-title">{{ $t('app.logoText') }}</span>
			<span class="logo-sub">Low Code Platform</span>
		</div>
	</div>
	<div v-else class="sidebar-logo sidebar-logo-mini">
		<div class="logo-mark">
			<img class="logo-img" src="/logo.png" alt="ICEJZ" />
			<span class="logo-shine" aria-hidden="true"></span>
		</div>
	</div>
</template>

<script setup lang="ts">
import { useAppStore } from '@/store/modules/app'
const appStore = useAppStore()
</script>

<style lang="scss" scoped>
.sidebar-logo {
	display: flex;
	align-items: center;
	gap: 12px;
	height: 74px;
	padding: 0 16px;
	box-sizing: border-box;
	color: var(--theme-logo-text-color);
	overflow: hidden;
}

.logo-mark {
	position: relative;
	width: 42px;
	height: 42px;
	border-radius: 13px;
	display: grid;
	place-items: center;
	flex-shrink: 0;
	overflow: hidden;
	background: linear-gradient(145deg, rgba(0, 168, 232, 0.22), rgba(62, 198, 255, 0.08));
	border: 1px solid rgba(0, 168, 232, 0.2);
	box-shadow:
		0 10px 20px rgba(0, 168, 232, 0.16),
		inset 0 1px 0 rgba(255, 255, 255, 0.35);
}

.logo-shine {
	position: absolute;
	inset: 0;
	background: linear-gradient(120deg, transparent 30%, rgba(255, 255, 255, 0.28), transparent 70%);
	transform: translateX(-120%);
	animation: logo-shine 4.5s ease-in-out infinite;
	pointer-events: none;
}

@keyframes logo-shine {
	0%,
	60% {
		transform: translateX(-120%);
	}
	80%,
	100% {
		transform: translateX(120%);
	}
}

.logo-img {
	position: relative;
	z-index: 1;
	width: 26px;
	height: 26px;
	border-radius: 7px;
	object-fit: cover;
}

.logo-text-wrap {
	display: flex;
	flex-direction: column;
	gap: 3px;
	min-width: 0;
	line-height: 1.15;
}

.logo-title {
	font-size: 16px;
	font-weight: 760;
	letter-spacing: 0.4px;
}

.logo-sub {
	font-size: 11px;
	opacity: 0.5;
	letter-spacing: 0.4px;
}

.sidebar-logo-mini {
	justify-content: center;
	padding: 0;
	height: 74px;

	.logo-mark {
		width: 44px;
		height: 44px;
	}

	.logo-img {
		width: 28px;
		height: 28px;
	}
}
</style>
