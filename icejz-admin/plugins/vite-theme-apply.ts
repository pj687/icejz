import type { Plugin, Connect } from 'vite'
import { parseTheme, writeThemeConfig } from '../scripts/theme-config-utils.mjs'

const ENDPOINT = '/__icejz/theme-apply'

const readBody = (req: Connect.IncomingMessage): Promise<string> =>
	new Promise((resolve, reject) => {
		const chunks: Buffer[] = []
		req.on('data', (chunk) => chunks.push(Buffer.from(chunk)))
		req.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')))
		req.on('error', reject)
	})

const sendJson = (res: Connect.ServerResponse, status: number, payload: Record<string, unknown>) => {
	res.statusCode = status
	res.setHeader('Content-Type', 'application/json;charset=utf-8')
	res.end(JSON.stringify(payload))
}

/**
 * 开发环境接口：布局设置「一键替换」直接写入 src/store/theme/config.ts
 */
export function themeApplyPlugin(): Plugin {
	return {
		name: 'icejz-theme-apply',
		configureServer(server) {
			server.middlewares.use(async (req, res, next) => {
				const url = req.url?.split('?')[0]
				if (url !== ENDPOINT) {
					next()
					return
				}

				if (req.method === 'OPTIONS') {
					res.statusCode = 204
					res.end()
					return
				}

				if (req.method !== 'POST') {
					sendJson(res, 405, { ok: false, message: 'Method Not Allowed' })
					return
				}

				try {
					const raw = await readBody(req)
					const theme = parseTheme(raw, '一键替换')
					const path = writeThemeConfig(server.config.root, theme)
					sendJson(res, 200, {
						ok: true,
						message: '已写入项目默认主题配置',
						path
					})
				} catch (error) {
					sendJson(res, 400, {
						ok: false,
						message: error instanceof Error ? error.message : '写入失败'
					})
				}
			})
		}
	}
}
