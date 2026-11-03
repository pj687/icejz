<template>
	<div class="layout-container layout-transverse" :class="{ 'is-nav-collapsed': !appStore.sidebarOpened }">
		<div class="tx-chrome" :class="headerClass">
			<header class="tx-header">
				<div class="tx-brand" v-if="theme.isLogo">
					<Logo />
				</div>

				<div class="tx-fold" title="折叠/展开菜单">
					<Hamburger />
				</div>

				<nav class="tx-nav" aria-label="main">
					<el-menu
						:default-active="defaultActive"
						background-color="transparent"
						:collapse-transition="false"
						mode="horizontal"
						:ellipsis="true"
						popper-class="tx-menu-popper"
						menu-trigger="hover"
					>
						<menu-item v-for="menu in routerStore.menuRoutes" :key="menu.path" :menu="menu"></menu-item>
					</el-menu>
				</nav>

				<div class="tx-actions">
					<NavbarRight />
				</div>
			</header>

			<div class="tx-tabs" v-if="theme.isTabsView">
				<Tabs />
			</div>
		</div>

		<div class="tx-body">
			<Main />
		</div>
	</div>
</template>

<script setup lang="ts">
import NavbarRight from '@/layout/components/Navbar/NavbarRight.vue'
import Hamburger from '@/layout/components/Navbar/components/Hamburger.vue'
import Main from '@/layout/components/Main/index.vue'
import Tabs from '@/layout/components/Tabs/index.vue'
import Logo from '@/layout/components/Logo/index.vue'
import MenuItem from '@/layout/components/Menu/MenuItem.vue'
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useRouterStore } from '@/store/modules/router'
import { useAppStore } from '@/store/modules/app'

const appStore = useAppStore()
const routerStore = useRouterStore()
const theme = computed(() => appStore.theme)
const route = useRoute()

const defaultActive = computed(() => route.fullPath)
const headerClass = computed(() => (appStore.theme.headerStyle === 'theme' ? 'header-theme' : ''))
</script>

<style lang="scss" scoped>
.layout-transverse {
	display: flex;
	flex-direction: column;
	width: 100%;
	height: 100%;
	margin: 0;
	padding: 0;
	gap: 0;
	overflow: hidden;
	background: var(--theme-main-bg-color);
}

.tx-chrome {
	flex-shrink: 0;
	width: 100%;
	margin: 0;
	padding: 0;
	border-radius: 0;
	background: var(--theme-header-bg-color, #fff);
	border-bottom: 1px solid var(--theme-border-color-light);
	box-shadow: none;
	z-index: 20;

	&.header-theme {
		background: var(--el-color-primary);
		border-bottom-color: transparent;

		:deep(.logo-title),
		:deep(.logo-sub),
		:deep(.navbar-right),
		:deep(.ma-icon),
		:deep(.tabs-action) {
			color: #fff !important;
		}

		:deep(.logo-mark) {
			background: rgba(255, 255, 255, 0.16);
			border-color: rgba(255, 255, 255, 0.28);
			box-shadow: none;
		}

		.tx-tabs {
			background: rgba(0, 0, 0, 0.08);
			border-top-color: rgba(255, 255, 255, 0.12);
		}

		:deep(.tabs-item-style-2 .el-tabs__item) {
			color: rgba(255, 255, 255, 0.78) !important;

			&:hover {
				color: #fff !important;
				background: rgba(255, 255, 255, 0.12) !important;
			}

			&.is-active {
				color: var(--el-color-primary) !important;
				background: #fff !important;

				.el-dropdown {
					color: var(--el-color-primary) !important;
				}
			}
		}
	}
}

.tx-header {
	--tx-h: 56px;
	height: var(--tx-h);
	padding: 0 16px 0 10px;
	display: flex;
	align-items: center;
	gap: 8px;
}

.tx-brand {
	flex-shrink: 0;
	display: flex;
	align-items: center;
	padding-right: 6px;
	margin-right: 0;

	:deep(.sidebar-logo),
	:deep(.sidebar-logo-mini) {
		height: 48px;
		padding: 0 6px;
		gap: 10px;
	}

	:deep(.logo-mark) {
		width: 34px;
		height: 34px;
		border-radius: 10px;
	}

	:deep(.logo-img) {
		width: 20px;
		height: 20px;
	}

	:deep(.logo-title) {
		font-size: 15px;
		font-weight: 760;
	}

	:deep(.logo-sub) {
		display: none;
	}
}

.tx-fold {
	flex-shrink: 0;
	display: flex;
	align-items: center;
	margin-right: 4px;
	padding-right: 8px;
	border-right: 1px solid rgba(15, 23, 36, 0.06);

	:deep(.ma-icon) {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		width: 34px;
		height: 34px;
		padding: 0;
		border-radius: 10px;
		cursor: pointer;
		color: var(--theme-menu-text-color, #4b5563);
		transition: background 0.18s ease, color 0.18s ease;

		&:hover {
			background: rgba(0, 168, 232, 0.08);
			color: var(--el-color-primary);
		}

		svg {
			width: 16px;
			height: 16px;
			vertical-align: 0;
		}
	}
}

.tx-nav {
	flex: 1;
	min-width: 0;
	overflow: hidden;

	:deep(.el-menu) {
		width: 100%;
		height: var(--tx-h);
		border-bottom: none !important;
		background: transparent !important;
	}

	:deep(.el-menu--horizontal > .el-menu-item),
	:deep(.el-menu--horizontal > .el-sub-menu .el-sub-menu__title) {
		display: inline-flex !important;
		align-items: center !important;
		justify-content: center !important;
		gap: 6px !important;
		height: 36px !important;
		line-height: 1 !important;
		margin: 10px 2px !important;
		padding: 0 12px !important;
		border-radius: 10px !important;
		border-bottom: none !important;
		color: var(--theme-menu-text-color, #4b5563) !important;
		font-size: 13.5px;
		font-weight: 600;
		background: transparent !important;
	}

	:deep(.el-menu--horizontal > .el-menu-item:hover),
	:deep(.el-menu--horizontal > .el-sub-menu .el-sub-menu__title:hover) {
		color: var(--el-color-primary) !important;
		background: rgba(0, 168, 232, 0.08) !important;
	}

	:deep(.el-menu--horizontal > .el-menu-item.is-active),
	:deep(.el-menu--horizontal > .el-sub-menu.is-active .el-sub-menu__title) {
		color: var(--el-color-primary) !important;
		background: rgba(0, 168, 232, 0.12) !important;
		font-weight: 720;
		box-shadow: none !important;
	}

	:deep(.el-menu--horizontal > .el-sub-menu .el-sub-menu__icon-arrow) {
		margin-left: 2px;
		font-size: 11px;
	}

	/* 顶栏菜单图标 */
	:deep(.menu-icon-wrap) {
		display: inline-flex !important;
		align-items: center;
		justify-content: center;
		width: 18px;
		height: 18px;
		margin: 0 !important;
		flex-shrink: 0;
		line-height: 1;
	}

	:deep(.menu-icon-wrap .ma-icon) {
		display: inline-flex !important;
		align-items: center;
		justify-content: center;
		width: 15px;
		height: 15px;
		line-height: 1;
	}

	:deep(.menu-icon-wrap .ma-icon svg),
	:deep(.menu-icon-wrap svg) {
		display: block !important;
		padding: 0;
		margin: 0;
		width: 15px !important;
		height: 15px !important;
		font-size: 15px !important;
		line-height: 1;
		vertical-align: 0 !important;
	}

	:deep(.menu-title) {
		display: inline-flex;
		align-items: center;
		line-height: 1;
		white-space: nowrap;
	}

	/* 溢出折叠：更多 (...) */
	:deep(.el-menu--horizontal > .el-sub-menu.is-active > .el-sub-menu__title),
	:deep(.el-sub-menu.el-sub-menu__hide-arrow > .el-sub-menu__title) {
		padding: 0 10px !important;
	}

	:deep(.el-menu--horizontal .el-menu__icon-more),
	:deep(.el-menu--horizontal > .el-sub-menu .el-sub-menu__icon-more) {
		font-size: 16px;
		transform: none;
	}
}

/* 折叠态：顶栏仅保留图标，下拉层仍显示完整文字 */
.layout-transverse.is-nav-collapsed {
	.tx-nav {
		:deep(.el-menu--horizontal > .el-menu-item),
		:deep(.el-menu--horizontal > .el-sub-menu > .el-sub-menu__title) {
			padding: 0 10px !important;
			min-width: 36px;
		}

		:deep(.el-menu--horizontal > .el-menu-item .menu-icon-wrap + .menu-title),
		:deep(.el-menu--horizontal > .el-sub-menu > .el-sub-menu__title .menu-icon-wrap + .menu-title) {
			display: none !important;
		}

		:deep(.el-menu--horizontal > .el-sub-menu > .el-sub-menu__title .el-sub-menu__icon-arrow) {
			display: none !important;
		}
	}
}

.tx-chrome.header-theme {
	.tx-fold {
		border-right-color: rgba(255, 255, 255, 0.18);

		:deep(.ma-icon) {
			color: rgba(255, 255, 255, 0.9);

			&:hover {
				background: rgba(255, 255, 255, 0.14);
				color: #fff;
			}
		}
	}

	.tx-nav {
		:deep(.el-menu--horizontal > .el-menu-item),
		:deep(.el-menu--horizontal > .el-sub-menu .el-sub-menu__title) {
			color: rgba(255, 255, 255, 0.86) !important;
		}

		:deep(.el-menu--horizontal > .el-menu-item:hover),
		:deep(.el-menu--horizontal > .el-sub-menu .el-sub-menu__title:hover),
		:deep(.el-menu--horizontal > .el-menu-item.is-active),
		:deep(.el-menu--horizontal > .el-sub-menu.is-active .el-sub-menu__title) {
			color: #fff !important;
			background: rgba(255, 255, 255, 0.16) !important;
		}
	}
}

.tx-actions {
	flex-shrink: 0;
	display: flex;
	align-items: center;
	padding-left: 8px;
	margin-left: 2px;
	border-left: 1px solid rgba(15, 23, 36, 0.06);

	:deep(.ma-icon) {
		height: 34px;
		line-height: 34px;
		padding: 0 9px;
		margin: 0 1px;
		border-radius: 10px;

		&:hover {
			background: rgba(0, 168, 232, 0.08);
			color: var(--el-color-primary);
		}
	}
}

.tx-chrome.header-theme .tx-actions {
	border-left-color: rgba(255, 255, 255, 0.18);

	:deep(.ma-icon:hover) {
		background: rgba(255, 255, 255, 0.14);
		color: #fff;
	}
}

.tx-tabs {
	border-top: 1px solid var(--theme-border-color-light);
	background: #f8fbfd;

	:deep(.tabs-container) {
		height: 40px;
		padding: 0 12px;
		background: transparent;
		border-bottom: none;
	}

	:deep(.tabs-action) {
		height: 40px;
		line-height: 40px;
		border-left-color: var(--theme-border-color-light);
	}
}

.tx-body {
	flex: 1;
	min-height: 0;
	width: 100%;
	margin: 0;
	padding: 0;
	border-radius: 0;
	overflow: hidden;
	background: var(--theme-main-bg-color);

	:deep(.layout-main) {
		background: var(--theme-main-bg-color) !important;
		border-radius: 0 !important;
		margin: 0 !important;
	}

	:deep(> .el-scrollbar) {
		height: 100%;
	}
}

@media (max-width: 960px) {
	.tx-brand :deep(.logo-text-wrap) {
		display: none;
	}

	.tx-brand {
		border-right: none;
		padding-right: 0;
		margin-right: 0;
	}
}
</style>

<!-- 全局兜底：强制取消横向布局的悬浮分块 / 圆角孤岛 -->
<style lang="scss">
.layout-transverse.layout-container,
.layout-transverse {
	display: flex !important;
	flex-direction: column !important;
	width: 100% !important;
	height: 100% !important;
	margin: 0 !important;
	padding: 0 !important;
	gap: 0 !important;
	border-radius: 0 !important;
	box-shadow: none !important;
	overflow: hidden !important;
}

.layout-transverse > .tx-chrome,
.layout-transverse > .tx-body {
	margin: 0 !important;
	padding: 0 !important;
	border-radius: 0 !important;
	box-shadow: none !important;
	width: 100% !important;
	max-width: none !important;
	left: auto !important;
	right: auto !important;
}

.layout-transverse > .tx-body {
	flex: 1 1 auto !important;
	min-height: 0 !important;
}

.layout-transverse .layout-main,
.layout-transverse .layout-main-wrap,
.layout-transverse .navbar-container {
	margin: 0 !important;
	border-radius: 0 !important;
	box-shadow: none !important;
}
</style>
