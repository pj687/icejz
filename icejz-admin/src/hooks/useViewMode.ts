import { ref, watch } from 'vue'

export type ViewMode = 'table' | 'card'

/**
 * 列表 / 卡片视图切换，偏好按页面 key 持久化到本机
 */
export const useViewMode = (storageKey: string, defaultMode: ViewMode = 'table') => {
	const key = `icejz-view-mode:${storageKey}`
	const cached = localStorage.getItem(key) as ViewMode | null
	const viewMode = ref<ViewMode>(cached === 'card' || cached === 'table' ? cached : defaultMode)

	watch(viewMode, (mode) => {
		localStorage.setItem(key, mode)
	})

	return { viewMode }
}
