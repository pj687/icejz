import { writeFileSync } from 'node:fs'
import { join } from 'node:path'

export const REQUIRED_KEYS = [
	'sidebarStyle',
	'headerStyle',
	'primaryColor',
	'layout',
	'uniqueOpened',
	'isLogo',
	'isBreadcrumb',
	'isTabsView',
	'isTabsCache',
	'tabsStyle'
]

export const parseTheme = (raw, source = '输入') => {
	let data
	try {
		data = JSON.parse(String(raw).replace(/^\uFEFF/, '').trim())
	} catch {
		throw new Error(`无法解析 JSON（来源：${source}）`)
	}
	if (!data || typeof data !== 'object' || Array.isArray(data)) {
		throw new Error(`主题配置必须是对象（来源：${source}）`)
	}
	const missing = REQUIRED_KEYS.filter((key) => !(key in data))
	if (missing.length) {
		throw new Error(`缺少字段：${missing.join(', ')}（来源：${source}）`)
	}
	const theme = {}
	for (const key of REQUIRED_KEYS) {
		theme[key] = data[key]
	}
	return theme
}

const formatValue = (value) => {
	if (typeof value === 'string') {
		return `'${value.replace(/\\/g, '\\\\').replace(/'/g, "\\'")}'`
	}
	return String(value)
}

export const buildConfigSource = (theme) => {
	const lines = REQUIRED_KEYS.map((key) => `\t${key}: ${formatValue(theme[key])}`)
	return [
		"import { ITheme } from '@/store/theme/interface'",
		'',
		'export const themeConfig: ITheme = {',
		lines.join(',\n'),
		'}',
		''
	].join('\n')
}

export const getThemeConfigPath = (rootDir) => join(rootDir, 'src/store/theme/config.ts')

export const writeThemeConfig = (rootDir, theme) => {
	const configPath = getThemeConfigPath(rootDir)
	writeFileSync(configPath, buildConfigSource(theme), 'utf8')
	return configPath
}
