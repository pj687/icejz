<template>
	<div class="tabs-container">
		<div class="tabs-item">
			<el-tabs v-model="activeTabName" :class="tabsStyleClass" @tab-click="tabClick" @tab-remove="tabRemove">
				<el-tab-pane v-for="tab in tabsStore.visitedViews" :key="tab" :label="tab.title" :name="tab.fullPath" :closable="!isAffix(tab)">
					<template #label>
						<el-dropdown
							:id="tab.fullPath"
							ref="dropdownRef"
							trigger="contextmenu"
							placement="bottom-end"
							@visible-change="handleChange($event, tab)"
							@command="onClose"
						>
							<span>{{ tabLabel(tab) }}</span>
							<template #dropdown>
								<el-dropdown-menu>
									<el-dropdown-item :icon="Close" command="close">{{ $t('app.close') }}</el-dropdown-item>
									<el-dropdown-item :icon="CircleClose" command="closeOthers">{{ $t('app.closeOthers') }}</el-dropdown-item>
									<el-dropdown-item :icon="CircleCloseFilled" command="closeAll">{{ $t('app.closeAll') }}</el-dropdown-item>
								</el-dropdown-menu>
							</template>
						</el-dropdown>
					</template>
				</el-tab-pane>
			</el-tabs>
		</div>
		<el-dropdown class="tabs-action" trigger="click" placement="bottom-end" @command="onClose">
			<template #dropdown>
				<el-dropdown-menu>
					<el-dropdown-item :icon="Close" command="close">{{ $t('app.close') }}</el-dropdown-item>
					<el-dropdown-item :icon="CircleClose" command="closeOthers">{{ $t('app.closeOthers') }}</el-dropdown-item>
					<el-dropdown-item :icon="CircleCloseFilled" command="closeAll">{{ $t('app.closeAll') }}</el-dropdown-item>
				</el-dropdown-menu>
			</template>
			<el-icon><arrow-down /></el-icon>
		</el-dropdown>
	</div>
</template>

<script setup lang="ts">
import { watch, onMounted, ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { closeAllTabs, closeOthersTabs, closeTab } from '@/utils/tabs'
import { ArrowDown, Close, CircleClose, CircleCloseFilled } from '@element-plus/icons-vue'
import { useAppStore } from '@/store/modules/app'
import { useRouterStore } from '@/store/modules/router'
import { useTabsStore } from '@/store/modules/tabs'
import { translateMenuTitle } from '@/utils/menu-i18n'

const appStore = useAppStore()
const routerStore = useRouterStore()
const tabsStore = useTabsStore()
const route = useRoute()
const router = useRouter()

const activeTabName = ref(route.fullPath)
const tabsStyleClass = computed(() => 'tabs-item-' + appStore.theme.tabsStyle)
const tabLabel = (tab: any) => translateMenuTitle(tab?.title || tab?.meta?.title, tab?.meta?.url || tab?.path)

// 是否固定
const isAffix = (tab: any) => {
	return tab.meta && tab.meta.affix
}

watch(route, () => {
	// 当前路由，添加到tabs里
	if (route.name) {
		addTab()
	}
})

onMounted(() => {
	// 初始化
	initTabs()
	addTab()
})

// 初始化固定tab
const initTabs = () => {
	const affixTabs = getAffixTabs(routerStore.routes)
	for (const tab of affixTabs) {
		// 需要有tab名称
		if (tab.name) {
			tabsStore.addView(tab)
		}
	}
}

// 获取需要固定的tabs
const getAffixTabs = (routes: any) => {
	let tabs: any[] = []
	routes.forEach((route: any) => {
		if (route.meta && route.meta.affix) {
			tabs.push({
				fullPath: route.path,
				path: route.path,
				name: route.name,
				meta: { ...route.meta }
			})
		}
		if (route.children) {
			const tempTabs = getAffixTabs(route.children)
			if (tempTabs.length >= 1) {
				tabs = [...tabs, ...tempTabs]
			}
		}
	})
	return tabs
}

// 添加tab
const addTab = () => {
	tabsStore.addView(route)
	tabsStore.addCachedView(route)
	activeTabName.value = route.fullPath
}

// tab被选中
const tabClick = (tab: any) => {
	tab.props.name && router.push(tab.props.name)
}

// 点击关闭tab
const tabRemove = (fullPath: string) => {
	const tab = tabsStore.visitedViews.filter((tab: any) => tab.fullPath === fullPath)
	closeTab(router, tab[0])
}

// dropdown 关闭事件
const onClose = (type: string) => {
	switch (type) {
		case 'close':
			closeTab(router, route)
			break
		case 'closeOthers':
			closeOthersTabs(router, route)
			break
		case 'closeAll':
			closeAllTabs(router, route)
			break
	}
}

// 保证右键标签页只会弹出当前一个下拉框
const dropdownRef = ref()
const handleChange = (visible: boolean, tab: any) => {
	if (!visible) {
		return
	}
	dropdownRef.value.forEach((item: { id: string; handleClose: () => void }) => {
		if (item.id === tab.fullPath) {
			return
		}
		item.handleClose()
	})
}
</script>

<style lang="scss" scoped>
.tabs-container {
	display: flex;
	position: relative;
	z-index: 6;
	height: 42px;
	padding: 0 8px;
	background: linear-gradient(180deg, #ffffff 0%, #f8fbfe 100%);
	border-bottom: 1px solid var(--theme-border-color-light);
	.tabs-item {
		transition: left 0.3s;
		flex-grow: 1;
		overflow: hidden;
		::v-deep(.el-tabs__header) {
			margin: 0;
		}
		::v-deep(.el-tabs__nav-wrap::after) {
			display: none;
		}
		::v-deep(.el-tabs__nav-prev),
		::v-deep(.el-tabs__nav-next) {
			padding: 0 10px;
			line-height: 42px;
		}
		::v-deep(.is-scrollable) {
			padding: 0 32px;
		}
		::v-deep(.el-tabs__active-bar) {
			height: 0;
		}
		::v-deep(.el-tabs__item) {
			.is-icon-close {
				transition: none !important;
				&:hover {
					color: #fff;
					background-color: var(--el-color-primary);
					border-radius: 50%;
				}
			}
		}
	}
}
.tabs-item-style-1 {
	::v-deep(.el-tabs__item) {
		padding: 0 16px !important;
		height: 42px;
		border-right: none;
		user-select: none;
		color: #8b93a7;
		&:hover {
			color: #374151;
			background: rgba(0, 168, 232, 0.04);
		}
		&.is-active {
			.el-dropdown {
				color: var(--el-color-primary) !important;
			}
			color: var(--el-color-primary);
			background-color: rgba(0, 168, 232, 0.08);
			box-shadow: inset 0 -2px 0 var(--el-color-primary);
			&:before {
				background-color: var(--el-color-primary);
			}
		}
		&:before {
			content: '';
			width: 8px;
			height: 8px;
			margin-right: 8px;
			display: inline-block;
			background-color: #d5dde8;
			border-radius: 50%;
		}
	}
}
.tabs-item-style-2 {
	::v-deep(.el-tabs__nav) {
		display: flex;
		align-items: center;
		gap: 6px;
		padding: 4px 0;
	}
	::v-deep(.el-tabs__item) {
		padding: 0 14px !important;
		height: 30px !important;
		line-height: 30px !important;
		margin: 0 2px;
		border-right: none;
		border-radius: 999px;
		user-select: none;
		color: #8b93a7;
		background: transparent;

		&:hover {
			color: #374151;
			background: rgba(15, 23, 36, 0.04);
		}

		&.is-active {
			.el-dropdown {
				color: #fff !important;
			}
			color: #fff !important;
			background: linear-gradient(135deg, #00a8e8, #3ec6ff) !important;
			box-shadow: 0 6px 14px rgba(0, 168, 232, 0.28);
		}
	}
}
.tabs-action {
	height: 42px;
	line-height: 42px;
	box-sizing: border-box;
	padding: 0 14px;
	align-items: center;
	cursor: pointer;
	color: #6b7280;
	border-left: 1px solid var(--theme-border-color-light);
}
</style>
