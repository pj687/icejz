<template>
	<el-sub-menu v-if="menu.children?.length > 0" :key="menu.path" :index="menu.path" class="icejz-sub-menu">
		<template #title>
			<span v-if="hasIcon(menu)" class="menu-icon-wrap">
				<ma-icon :icon="menu.meta.icon" />
			</span>
			<span class="menu-title">{{ menuTitle(menu) }}</span>
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
		<span v-if="hasIcon(menu)" class="menu-icon-wrap">
			<ma-icon :icon="menu.meta.icon" />
		</span>
		<span class="menu-title">{{ menuTitle(menu) }}</span>
	</el-menu-item>
</template>

<script setup lang="ts">
import { PropType } from 'vue'
import { useRouter } from 'vue-router'
import { isExternalLink, replaceLinkParam } from '@/utils/tool'
import { translateMenuTitle } from '@/utils/menu-i18n'

const hasIcon = (menu: any) => !!menu?.meta?.icon
const menuTitle = (menu: any) => translateMenuTitle(menu?.meta?.title, menu?.meta?.url)

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
