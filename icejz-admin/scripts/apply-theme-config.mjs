/**
 * 命令行兜底：一键将主题 JSON 写入 src/store/theme/config.ts
 *
 * 开发环境优先在布局设置中点击「一键替换」。
 *
 * 用法：
 *   npm run theme:apply
 *   npm run theme:apply -- path/to/theme-config.json
 */
import { execSync } from 'node:child_process'
import { existsSync, readFileSync } from 'node:fs'
import { dirname, isAbsolute, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { parseTheme, writeThemeConfig } from './theme-config-utils.mjs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const rootDir = resolve(__dirname, '..')
const defaultJsonPath = join(rootDir, 'theme-config.json')

const readClipboard = () => {
	try {
		if (process.platform === 'win32') {
			return execSync('powershell -NoProfile -Command Get-Clipboard', {
				encoding: 'utf8',
				windowsHide: true
			})
		}
		if (process.platform === 'darwin') {
			return execSync('pbpaste', { encoding: 'utf8' })
		}
		return execSync('xclip -selection clipboard -o', { encoding: 'utf8' })
	} catch {
		return ''
	}
}

const loadTheme = () => {
	const argPath = process.argv[2]
	if (argPath) {
		const filePath = isAbsolute(argPath) ? argPath : resolve(process.cwd(), argPath)
		if (!existsSync(filePath)) {
			throw new Error(`找不到文件：${filePath}`)
		}
		return parseTheme(readFileSync(filePath, 'utf8'), filePath)
	}

	if (existsSync(defaultJsonPath)) {
		return parseTheme(readFileSync(defaultJsonPath, 'utf8'), defaultJsonPath)
	}

	const clip = readClipboard().trim()
	if (clip) {
		return parseTheme(clip, '剪贴板')
	}

	throw new Error('未找到主题配置。请先在布局设置中点击「一键替换」，或传入 JSON 文件路径。')
}

try {
	const theme = loadTheme()
	const configPath = writeThemeConfig(rootDir, theme)
	console.log('已写入项目默认主题：')
	console.log(`  ${configPath}`)
	console.log(JSON.stringify(theme, null, 2))
} catch (error) {
	console.error(error instanceof Error ? error.message : error)
	process.exit(1)
}
