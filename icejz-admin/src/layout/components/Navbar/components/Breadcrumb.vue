<template>
	<el-breadcrumb separator="/" :separator-icon="ArrowRight" class="navbar-breadcrumb">
		<el-breadcrumb-item key="home">
			<span>{{ $t('home') }}</span>
		</el-breadcrumb-item>
		<el-breadcrumb-item v-for="(item, index) in breadcrumb" :key="index">
			<span>{{ item }}</span>
		</el-breadcrumb-item>
	</el-breadcrumb>
</template>

<script setup lang="ts">
import { useRoute } from 'vue-router'
import { ArrowRight } from '@element-plus/icons-vue'
import { computed } from 'vue'
import { translateMenuTitle } from '@/utils/menu-i18n'

const route = useRoute()
const breadcrumb = computed(() => {
	const list = (route.meta.breadcrumb as string[]) || []
	return list.map(item => translateMenuTitle(item))
})
</script>

<style lang="scss" scoped>
.navbar-breadcrumb {
	::v-deep(.el-breadcrumb__inner) {
		color: var(--theme-header-text-color) !important;
	}
	padding-left: 10px;
}

@media only screen and (max-width: 1200px) {
	.navbar-breadcrumb {
		display: none;
	}
}
</style>
