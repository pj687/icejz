<template>
	<el-container class="layout-container layout-vertical">
		<el-aside class="layout-sidebar" :class="sidebarClass">
			<div class="sidebar-shell">
				<div class="sidebar-glow" aria-hidden="true"></div>

				<div class="sidebar-top">
					<Logo v-if="appStore.theme.isLogo" />
					<div class="sidebar-divider" v-show="appStore.sidebarOpened"></div>
				</div>

				<div class="sidebar-menu">
					<el-scrollbar class="sidebar-scroll">
						<div class="menu-label" v-show="appStore.sidebarOpened">
							<span class="label-text">{{ $t('layout.navMenu') }}</span>
							<span class="label-line"></span>
						</div>
						<el-menu
							:default-active="defaultActive"
							:collapse="!appStore.sidebarOpened"
							:unique-opened="appStore.theme.uniqueOpened"
							background-color="transparent"
							:collapse-transition="false"
							mode="vertical"
						>
							<menu-item v-for="menu in routerStore.menuRoutes" :key="menu.path" :menu="menu" />
						</el-menu>
					</el-scrollbar>
				</div>

				<div class="sidebar-foot" v-show="appStore.sidebarOpened">
					<div class="foot-card">
						<div class="foot-icon">
							<span class="foot-dot"></span>
						</div>
						<div class="foot-text">
							<strong>ICEJZ Engine</strong>
							<em>Low-code console</em>
						</div>
					</div>
				</div>
			</div>
		</el-aside>

		<el-container class="layout-main-wrap">
			<el-header class="layout-header" :style="layoutHeaderHeight">
				<div class="navbar-container" :class="headerClass">
					<NavbarLeft />
					<NavbarRight />
				</div>
				<Tabs v-if="theme.isTabsView" />
			</el-header>
			<Main />
		</el-container>
	</el-container>
</template>

<script setup lang="ts">
import NavbarLeft from '@/layout/components/Navbar/NavbarLeft.vue'
import NavbarRight from '@/layout/components/Navbar/NavbarRight.vue'
import Main from '@/layout/components/Main/index.vue'
import Tabs from '@/layout/components/Tabs/index.vue'
import Logo from '@/layout/components/Logo/index.vue'
import MenuItem from '@/layout/components/Menu/MenuItem.vue'
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAppStore } from '@/store/modules/app'
import { useRouterStore } from '@/store/modules/router'

const appStore = useAppStore()
const routerStore = useRouterStore()
const route = useRoute()

const defaultActive = computed(() => route.fullPath)
const headerClass = computed(() => (appStore.theme.headerStyle === 'theme' ? 'header-theme' : ''))
const sidebarClass = computed(() => {
	const sidebarOpened = appStore.sidebarOpened ? 'aside-expend' : 'aside-compress'
	const isDark = appStore.theme.sidebarStyle === 'dark' ? 'sidebar-dark' : ''
	return `${sidebarOpened} ${isDark}`
})
const theme = computed(() => appStore.theme)
const layoutHeaderHeight = computed(() => {
	if (!theme.value.isTabsView) {
		return 'height:var(--theme-header-height) !important'
	}
	return ''
})
</script>

<style lang="scss" scoped>
.layout-vertical {
	background: var(--theme-main-bg-color);
}

.sidebar-shell {
	position: relative;
	display: flex;
	flex-direction: column;
	height: 100%;
	min-height: 0;
	overflow: hidden;
}

.sidebar-glow {
	position: absolute;
	top: -40px;
	left: -30px;
	width: 180px;
	height: 180px;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(0, 168, 232, 0.22), transparent 68%);
	pointer-events: none;
	z-index: 0;
}

.sidebar-top,
.sidebar-menu,
.sidebar-foot {
	position: relative;
	z-index: 1;
}

.sidebar-top {
	flex-shrink: 0;
}

.sidebar-divider {
	height: 1px;
	margin: 0 14px 4px;
	background: linear-gradient(90deg, transparent, rgba(0, 168, 232, 0.22), transparent);
}

.sidebar-menu {
	flex: 1;
	min-height: 0;
	display: flex;
	flex-direction: column;
}

.sidebar-scroll {
	flex: 1;
	height: 100%;
}

.menu-label {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 12px 14px 10px;
}

.label-text {
	flex-shrink: 0;
	font-size: 11px;
	font-weight: 700;
	letter-spacing: 1.2px;
	text-transform: uppercase;
	color: var(--theme-menu-text-color);
	opacity: 0.42;
}

.label-line {
	flex: 1;
	height: 1px;
	background: linear-gradient(90deg, rgba(0, 168, 232, 0.2), transparent);
}

.sidebar-foot {
	flex-shrink: 0;
	padding: 8px 12px 14px;
}

.foot-card {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 11px 12px;
	border-radius: 14px;
	background:
		radial-gradient(120% 100% at 0% 0%, rgba(0, 168, 232, 0.12), transparent 55%),
		rgba(0, 168, 232, 0.05);
	border: 1px solid rgba(0, 168, 232, 0.12);
}

.foot-icon {
	width: 30px;
	height: 30px;
	border-radius: 10px;
	display: grid;
	place-items: center;
	background: rgba(0, 168, 232, 0.12);
	border: 1px solid rgba(0, 168, 232, 0.14);
	flex-shrink: 0;
}

.foot-dot {
	width: 8px;
	height: 8px;
	border-radius: 50%;
	background: #00a8e8;
	box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.16);
}

.foot-text {
	min-width: 0;
	display: flex;
	flex-direction: column;
	gap: 2px;

	strong {
		font-size: 12.5px;
		font-weight: 700;
		color: var(--theme-menu-text-color);
	}

	em {
		font-style: normal;
		font-size: 11px;
		opacity: 0.55;
		color: var(--theme-menu-text-color);
	}
}

.layout-main-wrap {
	min-width: 0;
}

.navbar-container {
	height: var(--theme-header-height);
	display: flex;
	align-items: center;
	background: var(--theme-header-bg-color);
	backdrop-filter: blur(12px);
	border-bottom: 1px solid var(--theme-border-color-light);
	color: var(--theme-header-text-color);
	box-shadow: 0 1px 0 rgba(15, 23, 36, 0.02);

	:deep(.ma-icon) {
		align-items: center;
		cursor: pointer;
		height: 36px;
		line-height: 36px;
		padding: 0 10px;
		margin: 0 2px;
		border-radius: 10px;
		svg {
			color: var(--theme-header-text-color) !important;
			font-size: 16px;
		}
		&:hover {
			background: var(--theme-header-hover-color);
		}
	}
}
</style>

<style lang="scss">
.layout-vertical {
	.layout-sidebar {
		margin: 12px 0 12px 12px;
		height: calc(100% - 24px) !important;
		border-radius: 22px;
		border-right: none !important;
		overflow: hidden;
		box-shadow:
			0 18px 40px rgba(15, 23, 36, 0.08),
			0 0 0 1px rgba(15, 23, 36, 0.04);

		&.aside-expend {
			width: var(--theme-sidebar-width) !important;
		}

		&.aside-compress {
			width: 84px !important;
		}
	}

	.layout-main-wrap {
		padding: 12px 12px 12px 10px;
	}

	.layout-header {
		border-radius: 18px 18px 0 0;
		overflow: hidden;
		background: transparent;
	}

	.navbar-container {
		border-radius: 18px 18px 0 0;
	}

	.layout-main {
		border-radius: 0 0 18px 18px;
		overflow: hidden;
	}
}

.sidebar-dark .sidebar-divider {
	background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.12), transparent);
}

.sidebar-dark .label-line {
	background: linear-gradient(90deg, rgba(255, 255, 255, 0.16), transparent);
}

.sidebar-dark .foot-card {
	background:
		radial-gradient(120% 100% at 0% 0%, rgba(0, 168, 232, 0.18), transparent 55%),
		rgba(255, 255, 255, 0.04);
	border-color: rgba(255, 255, 255, 0.08);
}

.sidebar-dark .foot-icon {
	background: rgba(255, 255, 255, 0.08);
	border-color: rgba(255, 255, 255, 0.1);
}

.sidebar-dark .foot-text strong,
.sidebar-dark .foot-text em {
	color: rgba(255, 255, 255, 0.9);
}
</style>
