import { i18n } from '@/i18n'

const normalizeUrl = (url?: string) => {
	if (!url) return ''
	return String(url)
		.replace(/^#/, '')
		.replace(/^\//, '')
		.replace(/\?.*$/, '')
		.replace(/^p\.\d+\.?/, '')
		.replace(/\/+/g, '.')
}

const hasMsg = (key: string) => {
	const te = i18n.global.te as (key: string) => boolean
	try {
		return te(key)
	} catch {
		return false
	}
}

/**
 * 菜单标题国际化：优先按 url，其次按中文原名映射，最后回退原文。
 * 后端菜单多为中文 name，前端在展示时翻译，切换语言无需改库。
 */
export const translateMenuTitle = (title?: string, url?: string): string => {
	const raw = (title || '').trim()
	const t = i18n.global.t as (key: string) => string

	const urlKey = normalizeUrl(url)
	if (urlKey) {
		const key = `menus.url.${urlKey}`
		if (hasMsg(key)) return t(key)
	}

	if (raw) {
		const key = `menus.name.${raw}`
		if (hasMsg(key)) return t(key)
	}

	return raw
}

export const translateMenuRoute = (routeLike?: { meta?: any; path?: string }): string => {
	if (!routeLike) return ''
	return translateMenuTitle(routeLike.meta?.title, routeLike.meta?.url || routeLike.path)
}
