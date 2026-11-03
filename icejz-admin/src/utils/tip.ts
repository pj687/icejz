import { ElMessage, ElMessageBox } from 'element-plus'

type TipType = 'success' | 'warning' | 'error' | 'info'

const escapeHtml = (s: string) =>
	s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

const shouldUseDialog = (text: string) =>
	text.length > 36 || /封禁|无法登录|永久封禁|解封时间|账号已被/.test(text)

const tipTitle = (text: string, type: TipType, title?: string) => {
	if (title) {
		return title
	}
	if (/登录超时|重新登录|会话/.test(text)) {
		return '登录已失效'
	}
	if (/封禁/.test(text)) {
		return '账号暂不可用'
	}
	if (/验证码/.test(text)) {
		return '验证未通过'
	}
	if (type === 'success') {
		return '操作成功'
	}
	if (type === 'warning') {
		return '请注意'
	}
	if (type === 'info') {
		return '提示'
	}
	return '操作未完成'
}

const tipIcon = (type: TipType) => {
	const map: Record<TipType, string> = {
		error: '!',
		warning: '!',
		success: '✓',
		info: 'i'
	}
	return map[type]
}

const splitParagraphs = (text: string) => {
	const parts = text
		.split(/[。！？\n]+/)
		.map(s => s.trim())
		.filter(Boolean)
	if (parts.length <= 1) {
		return [text]
	}
	return parts.map(p => (/[。！？]$/.test(p) ? p : `${p}。`))
}

const buildDialogHtml = (text: string, type: TipType, title?: string) => {
	const paras = splitParagraphs(text)
		.map(p => `<p>${escapeHtml(p)}</p>`)
		.join('')
	return `
		<div class="icejz-tip-card icejz-tip-card--${type}">
			<div class="icejz-tip-icon" aria-hidden="true"><span>${tipIcon(type)}</span></div>
			<div class="icejz-tip-copy">
				<strong>${escapeHtml(tipTitle(text, type, title))}</strong>
				<div class="icejz-tip-paras">${paras}</div>
			</div>
		</div>
	`
}

let dialogOpen = false

type TipDialogOptions = {
	type?: TipType
	title?: string
	confirmText?: string
	showClose?: boolean
	closeOnClickModal?: boolean
}

export const showTipDialog = (message: string, typeOrOpts: TipType | TipDialogOptions = 'error') => {
	const opts: TipDialogOptions = typeof typeOrOpts === 'string' ? { type: typeOrOpts } : typeOrOpts || {}
	const type = opts.type || 'error'
	const text = (message || '请求失败').trim()
	if (dialogOpen) {
		return Promise.resolve()
	}
	dialogOpen = true
	return ElMessageBox.alert(buildDialogHtml(text, type, opts.title), '', {
		dangerouslyUseHTMLString: true,
		customClass: `icejz-tip-box icejz-tip-box--${type}`,
		showClose: opts.showClose !== false,
		closeOnClickModal: opts.closeOnClickModal !== false,
		closeOnPressEscape: true,
		confirmButtonText: opts.confirmText || '我知道了',
		center: false,
		roundButton: true
	})
		.catch(() => undefined)
		.finally(() => {
			dialogOpen = false
		})
}

/** 登录超时等必须确认后再跳转的温馨弹窗 */
export const showSessionTip = (message = '当前登录状态已失效，请重新登录后继续使用。') => {
	const text = message.trim()
	if (dialogOpen) {
		return Promise.resolve()
	}
	dialogOpen = true
	return ElMessageBox.confirm(buildDialogHtml(text, 'warning', '登录已失效'), '', {
		dangerouslyUseHTMLString: true,
		customClass: 'icejz-tip-box icejz-tip-box--warning',
		showCancelButton: false,
		showClose: false,
		closeOnClickModal: false,
		closeOnPressEscape: false,
		confirmButtonText: '重新登录',
		center: false,
		roundButton: true
	}).finally(() => {
		dialogOpen = false
	})
}

export const showToast = (message: string, type: TipType = 'error') => {
	const text = (message || '请求失败').trim()
	const duration = Math.min(6500, Math.max(2600, 1800 + text.length * 45))
	return ElMessage({
		type,
		message: text,
		duration,
		showClose: text.length > 18,
		grouping: true,
		customClass: `icejz-toast icejz-toast--${type}`
	})
}

/** API / 业务错误：短提示用 Toast，长提示或封禁类用弹窗 */
export const showApiError = (message?: string) => {
	const text = (message || '请求失败').trim()
	if (shouldUseDialog(text)) {
		return showTipDialog(text, 'error')
	}
	return showToast(text, 'error')
}

export const showApiSuccess = (message?: string) => showToast(message || '操作成功', 'success')
export const showApiWarning = (message?: string) => {
	const text = (message || '请注意').trim()
	if (shouldUseDialog(text)) {
		return showTipDialog(text, 'warning')
	}
	return showToast(text, 'warning')
}
