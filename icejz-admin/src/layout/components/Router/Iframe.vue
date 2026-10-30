<template>
	<div class="iframe-wrap" v-loading="loading">
		<iframe :src="url" class="iframe" @load="load"></iframe>
	</div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { RouteLocationNormalizedLoaded, useRoute } from 'vue-router'
import { replaceLinkParam } from '@/utils/tool'

const route = useRoute()
const url = ref('')
const loading = ref(false)

watch(
	() => route,
	value => {
		if (value.path === '/iframe') {
			initUrl(value)
		}
	},
	{ deep: true }
)

onMounted(() => {
	initUrl(route)
})
const initUrl = (route: RouteLocationNormalizedLoaded): void => {
	loading.value = true

	const { meta, query } = route
	if (query.url) {
		url.value = query.url as string
	} else {
		url.value = replaceLinkParam(meta.url as string)
	}
}
const load = () => {
	loading.value = false
}
</script>

<style lang="scss" scoped>
.iframe-wrap {
	min-height: calc(100vh - 70px - var(--theme-header-height));
	border-radius: var(--theme-card-radius, 14px);
	overflow: hidden;
	background:
		radial-gradient(900px 320px at 10% -30%, rgba(0, 168, 232, 0.08), transparent 55%),
		transparent;
}

.iframe {
	display: block;
	min-height: calc(100vh - 70px - var(--theme-header-height));
	width: 100%;
	border: 0;
	background: transparent;
}
</style>
