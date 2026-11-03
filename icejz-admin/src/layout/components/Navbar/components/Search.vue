<template>
	<div class="navbar-search">
		<button type="button" class="search-trigger" :title="t('layout.menuSearch')" :aria-label="t('layout.menuSearch')" @click="openSearch">
			<ma-icon icon="icon-search" />
		</button>

		<Teleport to="body">
			<div v-if="visible" class="menu-search-layer" @mousedown.self="closeSearch">
				<div class="search-box" role="dialog" :aria-label="t('layout.menuSearch')" @mousedown.stop>
					<el-autocomplete
						ref="menuAutocompleteRef"
						v-model="menuValue"
						class="search-input"
						popper-class="menu-search-popper"
						size="large"
						:prefix-icon="Search"
						:fetch-suggestions="menuSearch"
						:trigger-on-focus="true"
						:fit-input-width="true"
						:placeholder="t('layout.menuSearch')"
						@select="handleSelect"
						@keydown.esc="closeSearch"
					>
						<template #default="{ item }">
							<div class="search-item">
								<span class="item-icon">
									<ma-icon :icon="item.meta.icon || 'icon-unorderedlist'" />
								</span>
								<span class="item-main">
									<span class="item-title">{{ itemTitle(item) }}</span>
									<span class="item-path">{{ item.path }}</span>
								</span>
								<span class="item-enter">{{ t('layout.enter') }}</span>
							</div>
						</template>
					</el-autocomplete>
					<button type="button" class="search-close" :title="t('close')" :aria-label="t('close')" @click="closeSearch">
						Esc
					</button>
				</div>
			</div>
		</Teleport>
	</div>
</template>

<script setup lang="ts">
import { Search } from '@element-plus/icons-vue'
import { nextTick, onBeforeUnmount, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { useRouterStore } from '@/store/modules/router'
import { translateMenuTitle } from '@/utils/menu-i18n'

const { t } = useI18n()
const routerStore = useRouterStore()
const router = useRouter()
const menuAutocompleteRef = ref()
const visible = ref(false)
const menuValue = ref('')

const itemTitle = (item: Restaurant) => translateMenuTitle(item?.meta?.title, item?.meta?.url || item?.path)

const openSearch = () => {
	visible.value = true
	nextTick(() => {
		setTimeout(() => {
			menuAutocompleteRef.value?.focus?.()
		}, 30)
	})
}

const closeSearch = () => {
	visible.value = false
	menuValue.value = ''
}

interface Restaurant {
	path: string
	meta: {
		title: string
		icon?: string
		url?: string
	}
}

const menuList = routerStore.searchMenu

const menuSearch = (queryString: string, cb: any) => {
	const results = queryString ? menuList.filter(createFilter(queryString)) : menuList
	cb(results.slice(0, 12))
}

const createFilter: any = (queryString: string) => {
	const q = queryString.toLowerCase()
	return (restaurant: Restaurant) => {
		const title = translateMenuTitle(restaurant.meta.title, restaurant.meta.url || restaurant.path)
		return (
			restaurant.path.toLowerCase().indexOf(q) > -1 ||
			restaurant.meta.title.toLowerCase().indexOf(q) > -1 ||
			title.toLowerCase().indexOf(q) > -1
		)
	}
}

const handleSelect = (item: Restaurant) => {
	router.push(item.path)
	closeSearch()
}

const onKeydown = (e: KeyboardEvent) => {
	if (e.key === 'Escape' && visible.value) {
		closeSearch()
	}
	if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
		e.preventDefault()
		openSearch()
	}
}

onMounted(() => {
	window.addEventListener('keydown', onKeydown)
})

onBeforeUnmount(() => {
	window.removeEventListener('keydown', onKeydown)
})
</script>

<style lang="scss" scoped>
.navbar-search {
	display: inline-flex;
	align-items: center;
}

.search-trigger {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: 34px;
	height: 34px;
	border: none;
	border-radius: 10px;
	background: transparent;
	color: inherit;
	cursor: pointer;
	transition: all 0.2s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.1);
		color: #00a8e8;
	}
}
</style>

<style lang="scss">
.menu-search-layer {
	position: fixed;
	inset: 0;
	z-index: 5000;
	/* 透明点击层：无灰暗遮罩，仅用于点空白关闭 */
	background: transparent;
}

.search-box {
	position: absolute;
	top: 72px;
	left: 50%;
	transform: translateX(-50%);
	display: flex;
	align-items: center;
	gap: 10px;
	width: min(560px, calc(100vw - 32px));
	padding: 10px 10px 10px 12px;
	border-radius: 16px;
	background: var(--icejz-card-bg, #fff);
	border: 1px solid rgba(0, 168, 232, 0.18);
	box-shadow:
		0 18px 48px rgba(15, 23, 36, 0.14),
		0 0 0 4px rgba(0, 168, 232, 0.08);
	animation: menu-search-in 0.18s ease;
}

@keyframes menu-search-in {
	from {
		opacity: 0;
		transform: translateX(-50%) translateY(-8px);
	}
	to {
		opacity: 1;
		transform: translateX(-50%) translateY(0);
	}
}

.search-box .search-input {
	flex: 1;
	min-width: 0;
}

.search-box .search-input .el-input__wrapper {
	min-height: 44px;
	padding: 0 12px;
	border-radius: 12px;
	background: #f5f9fc;
	box-shadow: 0 0 0 1px #d8e4ef inset !important;
}

.search-box .search-input .el-input__wrapper.is-focus {
	background: var(--icejz-card-bg, #fff);
	box-shadow:
		0 0 0 1px #00a8e8 inset,
		0 0 0 3px rgba(0, 168, 232, 0.12) !important;
}

.search-box .search-input .el-input__inner {
	font-size: 15px;
	color: #0f1724;
}

.search-box .search-input .el-input__prefix {
	color: #00a8e8;
	font-size: 18px;
}

.search-close {
	flex-shrink: 0;
	height: 32px;
	padding: 0 10px;
	border-radius: 8px;
	border: 1px solid #d9e4ee;
	background: #f5f8fb;
	color: #6b7c8d;
	font-size: 12px;
	font-weight: 650;
	cursor: pointer;
	transition: all 0.2s ease;

	&:hover {
		color: #0f1724;
		background: #eef3f7;
	}
}

.menu-search-popper.el-popper {
	z-index: 5001 !important;
	margin-top: 10px !important;
	border: 1px solid rgba(15, 23, 36, 0.08) !important;
	border-radius: 14px !important;
	overflow: hidden;
	box-shadow: 0 16px 40px rgba(15, 23, 36, 0.14) !important;
	background: var(--icejz-card-bg, #fff) !important;

	.el-popper__arrow {
		display: none;
	}

	.el-autocomplete-suggestion__wrap {
		max-height: 360px !important;
		padding: 6px !important;
	}

	.el-autocomplete-suggestion li {
		padding: 0 !important;
		margin-bottom: 2px;
		border-radius: 10px;
		line-height: 1.4;
		transition: background 0.15s ease;

		&:last-child {
			margin-bottom: 0;
		}

		&:hover,
		&.highlighted {
			background: rgba(0, 168, 232, 0.08) !important;
		}
	}
}

.search-item {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 10px 12px;
	min-height: 52px;
}

.item-icon {
	width: 34px;
	height: 34px;
	border-radius: 10px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
	color: #0090c8;
	background: rgba(0, 168, 232, 0.1);
	border: 1px solid rgba(0, 168, 232, 0.12);
}

.item-main {
	min-width: 0;
	flex: 1;
	display: flex;
	flex-direction: column;
	gap: 2px;
}

.item-title {
	font-size: 14px;
	font-weight: 650;
	color: #0f1724;
}

.item-path {
	font-size: 12px;
	color: #8b93a7;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.item-enter {
	flex-shrink: 0;
	padding: 3px 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 650;
	color: #0090c8;
	background: rgba(0, 168, 232, 0.08);
	opacity: 0;
	transition: opacity 0.15s ease;
}

.menu-search-popper .el-autocomplete-suggestion li:hover .item-enter,
.menu-search-popper .el-autocomplete-suggestion li.highlighted .item-enter {
	opacity: 1;
}
</style>
