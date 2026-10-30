<template>
	<el-sub-menu v-if="menu.children.length > 0" :key="menu.path" :index="menu.path" class="icejz-sub-menu">
		<template #title>
			<span v-if="showIcon" class="menu-icon-wrap">
				<ma-icon :icon="menu.meta.icon" />
			</span>
			<span class="menu-title">{{ menu.meta.title }}</span>
		</template>
		<menu-item v-for="sub in menu.children" :key="sub.path" :menu="sub" />
	</el-sub-menu>
	<el-menu-item
		v-else
		:key="menu.path"
		:index="menuIndex(menu)"
		class="icejz-menu-item"
		@click="handleClickMenu(menu)"
	>
		<span v-if="showIcon" class="menu-icon-wrap">
			<ma-icon :icon="menu.meta.icon" />
		</span>
		<template #title>
			<span class="menu-title">{{ menu.meta.title }}</span>
		</template>
	</el-menu-item>
</template>

<script setup lang="ts">
import { computed, PropType } from 'vue'
import { useRouter } from 'vue-router'
import { isExternalLink, replaceLinkParam } from '@/utils/tool'
import { useAppStore } from '@/store/modules/app'

const appStore = useAppStore()

const showIcon = computed(() => appStore.theme.layout !== 'columns')

defineProps({
	menu: {
		type: Object as PropType<any>,
		required: true
	}
})

const router = useRouter()

const menuIndex = (menu: any) => {
	if (menu.meta && menu.meta.url && menu.meta.url.indexOf('?') > -1 && !isExternalLink(menu.meta.url)) {
		return '/' + menu.meta.url
	}
	return menu.path
}

const handleClickMenu = (menu: any) => {
	if (!menu.meta.newOpen) {
		router.push(menuIndex(menu))
		return
	}

	if (isExternalLink(menu.meta.url)) {
		window.open(replaceLinkParam(menu.meta.url), '_blank')
	} else {
		window.open('#' + menu.meta.url, '_blank')
	}
}
</script>
