<template>
	<div class="iframe-wrap" v-loading="loading">
		<iframe ref="frameRef" :src="url" class="iframe" @load="onLoad"></iframe>
	</div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { RouteLocationNormalizedLoaded, useRoute } from 'vue-router'
import { replaceLinkParam } from '@/utils/tool'

const route = useRoute()
const url = ref('')
const loading = ref(false)
const frameRef = ref<HTMLIFrameElement | null>(null)
let themeObserver: MutationObserver | null = null

const isDark = () => document.documentElement.classList.contains('dark')

const pushTheme = () => {
	const win = frameRef.value?.contentWindow
	if (!win) return
	const dark = isDark()
	try {
		win.postMessage({ type: 'icejz-theme', dark }, '*')
	} catch {
		// ignore
	}
	try {
		win.document.documentElement.classList.toggle('dark', dark)
	} catch {
		// cross-origin
	}
}

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
	themeObserver = new MutationObserver(() => pushTheme())
	themeObserver.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] })
})

onBeforeUnmount(() => {
	themeObserver?.disconnect()
	themeObserver = null
})

const initUrl = (current: RouteLocationNormalizedLoaded): void => {
	loading.value = true

	const { meta, query } = current
	if (query.url) {
		url.value = query.url as string
	} else {
		url.value = replaceLinkParam(meta.url as string)
	}
}

const onLoad = () => {
	loading.value = false
	pushTheme()
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
