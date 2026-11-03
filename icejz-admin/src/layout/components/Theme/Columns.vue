<template>
	<div class="layout-container layout-columns">
		<aside class="col-rail" :class="sidebarClass">
			<div class="rail-logo" v-if="theme.isLogo" @click="goHome" title="ICEJZ">
				<img class="rail-logo-img" src="/logo.png" alt="ICEJZ" />
			</div>

			<el-scrollbar class="rail-scroll">
				<nav class="rail-menu" aria-label="一级导航">
					<button
						v-for="menu in routerStore.menuRoutes"
						:key="menu.path"
						type="button"
						class="rail-item"
						:class="{ active: menuPath === menu.path }"
						:title="railTitle(menu)"
						@click="handleMenu(menu)"
					>
						<span class="rail-icon">
							<ma-icon :icon="menu.meta?.icon" />
						</span>
						<span class="rail-title">{{ railTitle(menu) }}</span>
					</button>
				</nav>
			</el-scrollbar>
		</aside>

		<div class="col-body">
			<header class="col-header" :class="headerClass" :style="layoutHeaderHeight">
				<div class="navbar-container">
					<NavbarLeft />
					<NavbarRight />
				</div>
				<div class="col-tabs" v-if="theme.isTabsView">
					<Tabs />
				</div>
			</header>

			<div class="col-main">
				<aside v-if="subMenus.length > 0 && appStore.sidebarOpened" class="col-sub">
					<div class="col-sub-head">
						<span class="col-sub-kicker">{{ $t('layout.module') }}</span>
						<strong class="col-sub-title">{{ activeModuleTitle }}</strong>
					</div>
					<el-scrollbar class="col-sub-scroll">
						<el-menu
							:default-active="defaultActive"
							:unique-opened="appStore.theme.uniqueOpened"
							background-color="transparent"
							:collapse-transition="false"
							mode="vertical"
						>
							<menu-item v-for="menu in subMenus" :key="menu.path" :menu="menu"></menu-item>
						</el-menu>
					</el-scrollbar>
				</aside>

				<div class="col-content">
					<Main />
				</div>
			</div>
		</div>
	</div>
</template>

<script setup lang="ts">
import { useRouterStore } from '@/store/modules/router'
import { isExternalLink } from '@/utils/tool'
import { useAppStore } from '@/store/modules/app'
import NavbarLeft from '@/layout/components/Navbar/NavbarLeft.vue'
import NavbarRight from '@/layout/components/Navbar/NavbarRight.vue'
import Main from '@/layout/components/Main/index.vue'
import Tabs from '@/layout/components/Tabs/index.vue'
import MenuItem from '@/layout/components/Menu/MenuItem.vue'
import { translateMenuTitle } from '@/utils/menu-i18n'
import { computed, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { RouteRecordRaw, useRoute, useRouter } from 'vue-router'

const routerStore = useRouterStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const { t } = useI18n()

const defaultActive = computed(() => route.fullPath)
const theme = computed(() => appStore.theme)
const headerClass = computed(() => (appStore.theme.headerStyle === 'theme' ? 'header-theme' : ''))
const sidebarClass = computed(() => (appStore.theme.sidebarStyle === 'dark' ? 'sidebar-dark' : ''))

const layoutHeaderHeight = computed(() => {
	if (!theme.value.isTabsView) {
		return 'min-height: var(--theme-header-height)'
	}
	return ''
})

const subMenus = ref<any[]>([])
const menuPath = ref('')
const railTitle = (menu: any) => translateMenuTitle(menu?.meta?.title, menu?.meta?.url)
const activeModuleTitle = computed(() => {
	const mod = routerStore.menuRoutes.find((m: any) => m.path === menuPath.value)
	return translateMenuTitle(mod?.meta?.title, mod?.meta?.url) || t('layout.featureMenu')
})

watch(route, () => {
	subMenus.value = []
	initSubMenu()
})

onMounted(() => {
	initSubMenu()
})

const initSubMenu = () => {
	menuPath.value = defaultActive.value
	for (const menu of routerStore.menuRoutes) {
		const exist = findRoute(menu.children as RouteRecordRaw[])
		if (exist) {
			subMenus.value = (menu.children as RouteRecordRaw[]) || []
			menuPath.value = menu.path
			break
		}
	}
}

const findRoute = (menus: RouteRecordRaw[]): boolean => {
	if (!menus?.length) return false
	for (const menu of menus) {
		if (menu.children && menu.children.length > 0) {
			if (findRoute(menu.children)) return true
		} else if (menu.path === defaultActive.value || (menu.meta?.url && '/' + menu.meta.url === defaultActive.value)) {
			return true
		}
	}
	return false
}

const handleMenu = (menu: any) => {
	if (menu.children && menu.children.length > 0) {
		const leafRoute = findLeafRoute(menu.children)
		if (leafRoute) handleMenu(leafRoute)
	} else if (menu.meta && menu.meta.url && menu.meta.url.indexOf('?') > -1 && !isExternalLink(menu.meta.url)) {
		router.push('/' + menu.meta.url)
	} else {
		router.push(menu.path)
	}
}

const findLeafRoute = (menus: RouteRecordRaw[]): any => {
	for (const menu of menus) {
		if (menu.children && menu.children.length > 0) {
			return findLeafRoute(menu.children)
		}
		return menu
	}
	return null
}

const goHome = () => {
	router.push('/dashboard/index')
}
</script>

<style lang="scss" scoped>
.layout-columns {
	display: flex;
	width: 100%;
	height: 100%;
	overflow: hidden;
	background: var(--theme-main-bg-color);
}

/* 左侧一级图标轨 */
.col-rail {
	--rail-w: 84px;
	flex-shrink: 0;
	width: var(--rail-w);
	height: 100%;
	display: flex;
	flex-direction: column;
	background:
		radial-gradient(120% 70% at 0% 0%, rgba(0, 168, 232, 0.16), transparent 42%),
		linear-gradient(180deg, #0f1724 0%, #152033 48%, #101927 100%);
	border-right: 1px solid rgba(255, 255, 255, 0.06);
	box-shadow: 6px 0 24px rgba(8, 18, 32, 0.18);
	z-index: 30;
}

.rail-logo {
	flex-shrink: 0;
	height: 64px;
	display: flex;
	align-items: center;
	justify-content: center;
	cursor: pointer;
	border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.rail-logo-img {
	width: 36px;
	height: 36px;
	border-radius: 12px;
	object-fit: cover;
	box-shadow:
		0 8px 18px rgba(0, 168, 232, 0.28),
		0 0 0 1px rgba(255, 255, 255, 0.08);
	transition: transform 0.2s ease;
}

.rail-logo:hover .rail-logo-img {
	transform: translateY(-1px) scale(1.04);
}

.rail-scroll {
	flex: 1;
	min-height: 0;
}

.rail-menu {
	padding: 10px 8px 18px;
	display: flex;
	flex-direction: column;
	gap: 4px;
}

.rail-item {
	appearance: none;
	border: 0;
	background: transparent;
	width: 100%;
	min-height: 68px;
	padding: 10px 6px;
	border-radius: 14px;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	gap: 6px;
	cursor: pointer;
	transition:
		background 0.18s ease,
		transform 0.18s ease,
		box-shadow 0.18s ease;
	color: rgba(255, 255, 255, 0.72);

	&:hover {
		background: rgba(255, 255, 255, 0.08);
		color: #fff;
		transform: translateY(-1px);
	}

	&.active {
		background: linear-gradient(145deg, #00a8e8, #3ec6ff);
		color: #fff;
		box-shadow: 0 10px 22px rgba(0, 168, 232, 0.3);
	}
}

.rail-icon {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: 28px;
	height: 28px;

	:deep(.ma-icon) {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		line-height: 1;
	}

	:deep(svg) {
		width: 20px !important;
		height: 20px !important;
		font-size: 20px !important;
		color: currentColor !important;
		vertical-align: 0 !important;
	}
}

.rail-title {
	font-size: 11px;
	font-weight: 600;
	line-height: 1.2;
	letter-spacing: 0.2px;
	text-align: center;
	max-width: 100%;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

/* 浅色轨（非 dark 侧栏主题时仍保持深色轨，分栏更清晰；若要跟随可覆盖） */
.col-rail:not(.sidebar-dark) {
	background:
		radial-gradient(120% 70% at 50% 0%, rgba(0, 168, 232, 0.1), transparent 46%),
		linear-gradient(180deg, #f7fbfe 0%, #eef4f9 100%);
	border-right-color: rgba(15, 23, 36, 0.06);
	box-shadow: 4px 0 18px rgba(15, 23, 36, 0.04);

	.rail-logo {
		border-bottom-color: rgba(15, 23, 36, 0.06);
	}

	.rail-item {
		color: #64748b;

		&:hover {
			background: rgba(0, 168, 232, 0.1);
			color: var(--el-color-primary);
		}

		&.active {
			background: linear-gradient(145deg, #00a8e8, #3ec6ff);
			color: #fff;
		}
	}
}

.col-body {
	flex: 1;
	min-width: 0;
	min-height: 0;
	display: flex;
	flex-direction: column;
	overflow: hidden;
}

.col-header {
	flex-shrink: 0;
	background: var(--theme-header-bg-color, #fff);
	border-bottom: 1px solid var(--theme-border-color-light);
	z-index: 20;

	&.header-theme {
		background: var(--el-color-primary);
		border-bottom-color: transparent;

		:deep(.navbar-right),
		:deep(.ma-icon),
		:deep(.tabs-action) {
			color: #fff !important;
		}

		.col-tabs {
			background: rgba(0, 0, 0, 0.08);
			border-top-color: rgba(255, 255, 255, 0.12);
		}
	}
}

.navbar-container {
	height: var(--theme-header-height);
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 8px 0 4px;
	color: var(--theme-header-text-color);

	:deep(.ma-icon) {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		height: 36px;
		line-height: 1;
		padding: 0 10px;
		margin: 0 2px;
		border-radius: 10px;
		cursor: pointer;

		svg {
			color: var(--theme-header-text-color) !important;
			font-size: 16px;
			vertical-align: 0;
		}

		&:hover {
			background: var(--theme-header-hover-color, rgba(0, 168, 232, 0.08));
		}
	}
}

.col-tabs {
	border-top: 1px solid var(--theme-border-color-light);
	background: #f8fbfd;

	:deep(.tabs-container) {
		height: 40px;
		padding: 0 12px;
		background: transparent;
		border-bottom: none;
	}
}

.col-main {
	flex: 1;
	min-height: 0;
	display: flex;
	overflow: hidden;
}

.col-sub {
	flex-shrink: 0;
	width: 196px;
	height: 100%;
	display: flex;
	flex-direction: column;
	background: var(--icejz-card-bg, #fff);
	border-right: 1px solid var(--theme-border-color-light);
	box-shadow: 4px 0 18px rgba(15, 23, 36, 0.03);
}

.col-sub-head {
	flex-shrink: 0;
	padding: 16px 16px 12px;
	border-bottom: 1px solid rgba(15, 23, 36, 0.05);
}

.col-sub-kicker {
	display: block;
	font-size: 11px;
	font-weight: 650;
	letter-spacing: 0.08em;
	text-transform: uppercase;
	color: #94a3b8;
	margin-bottom: 4px;
}

.col-sub-title {
	display: block;
	font-size: 15px;
	font-weight: 720;
	color: #0f172a;
	line-height: 1.3;
}

.col-sub-scroll {
	flex: 1;
	min-height: 0;

	:deep(.el-menu) {
		border-right: none !important;
		background: transparent !important;
		padding: 10px 10px 16px !important;
	}

	:deep(.el-menu-item),
	:deep(.el-sub-menu__title) {
		display: flex !important;
		align-items: center !important;
		gap: 8px !important;
		height: 42px !important;
		line-height: 1 !important;
		margin: 3px 0 !important;
		padding: 0 12px !important;
		border-radius: 12px !important;
		color: #475569 !important;
	}

	:deep(.el-menu-item:hover),
	:deep(.el-sub-menu__title:hover) {
		background: rgba(0, 168, 232, 0.08) !important;
		color: var(--el-color-primary) !important;
	}

	:deep(.el-menu-item.is-active) {
		background: rgba(0, 168, 232, 0.12) !important;
		color: var(--el-color-primary) !important;
		font-weight: 680;
		box-shadow: inset 3px 0 0 var(--el-color-primary);
	}

	:deep(.menu-icon-wrap) {
		display: inline-flex !important;
		align-items: center;
		justify-content: center;
		width: 18px;
		height: 18px;
		margin: 0 !important;
		flex-shrink: 0;
		background: transparent !important;
		border: none !important;
		box-shadow: none !important;
	}

	:deep(.menu-icon-wrap .ma-icon),
	:deep(.menu-icon-wrap svg) {
		width: 15px !important;
		height: 15px !important;
		vertical-align: 0 !important;
	}

	:deep(.menu-title) {
		line-height: 1.2;
		white-space: nowrap;
	}
}

.col-content {
	flex: 1;
	min-width: 0;
	min-height: 0;
	overflow: hidden;
	background: var(--theme-main-bg-color);

	:deep(.layout-main) {
		border-radius: 0 !important;
		margin: 0 !important;
	}
}
</style>

<style lang="scss">
.layout-columns.layout-container {
	display: flex !important;
	width: 100% !important;
	height: 100% !important;
	overflow: hidden !important;
}

.layout-columns .col-sub .el-sub-menu .el-menu {
	margin-left: 8px !important;
	padding-left: 8px !important;
	background: transparent !important;

	&::before {
		display: none !important;
	}
}

.layout-columns .col-sub .el-sub-menu .el-menu-item::after {
	display: none !important;
}
</style>
