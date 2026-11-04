import { reactive } from 'vue'

export const toastState = reactive({
  show: false,
  leaving: false,
  title: '',
  sub: '',
  art: '',
  tone: 'info',
  iconMark: ''
})

let showTimer = null
let leaveTimer = null
let hostCount = 0

function clearTimers() {
  if (showTimer) {
    clearTimeout(showTimer)
    showTimer = null
  }
  if (leaveTimer) {
    clearTimeout(leaveTimer)
    leaveTimer = null
  }
}

function resolveTone(options = {}) {
  if (options.tone) return options.tone
  const icon = options.icon || 'none'
  if (icon === 'success') return 'ok'
  if (icon === 'error' || icon === 'fail') return 'fail'
  // icon:none 但标题明显为成功语义时，仍走成功态
  const title = String(options.title || options.msg || '')
  if (/成功|已读|已保存|已删除|完成|已发送|已更新|ok/i.test(title)) return 'ok'
  if (/失败|错误|无效|必填|请先|请输入|请选择|fail|error/i.test(title)) return 'fail'
  return 'info'
}

function resolveMark(tone, hasArt) {
  if (hasArt) return ''
  if (tone === 'ok') return '✓'
  if (tone === 'fail') return '!'
  return '·'
}

function resolveNativeIcon(tone, icon) {
  if (icon && icon !== 'none') return icon
  if (tone === 'ok') return 'success'
  if (tone === 'fail') return 'none'
  return 'none'
}

export function registerIceToastHost() {
  hostCount += 1
}

export function unregisterIceToastHost() {
  hostCount = Math.max(0, hostCount - 1)
}

/**
 * 自定义 Toast
 * @param {object} options
 * @param {string} options.title
 * @param {string} [options.sub]
 * @param {string} [options.art] 插画/图片
 * @param {string} [options.tone] ok | fail | info | male | female | unknown
 * @param {string} [options.icon] 兼容 uni.showToast: success | none | error | fail
 * @param {number} [options.duration]
 */
export function showIceToast(options = {}) {
  const title = options.title || options.msg || ''
  if (!title) return

  const tone = resolveTone(options)
  const art = options.art || options.image || ''
  const sub = options.sub || ''
  const duration = typeof options.duration === 'number' ? options.duration : 1600

  // 当前页未挂载宿主时回退原生，避免提示丢失
  if (hostCount <= 0 && typeof uni !== 'undefined' && uni.__rawShowToast) {
    uni.__rawShowToast({
      title,
      icon: resolveNativeIcon(tone, options.icon),
      duration,
      mask: !!options.mask
    })
    return
  }

  clearTimers()
  toastState.show = true
  toastState.leaving = false
  toastState.title = title
  toastState.sub = sub
  toastState.art = art
  toastState.tone = tone
  toastState.iconMark = resolveMark(tone, !!art)

  showTimer = setTimeout(() => {
    toastState.leaving = true
    leaveTimer = setTimeout(() => {
      toastState.show = false
      toastState.leaving = false
      showTimer = null
      leaveTimer = null
    }, 220)
  }, duration)
}

export function hideIceToast() {
  clearTimers()
  if (!toastState.show) {
    if (typeof uni !== 'undefined' && uni.__rawHideToast) uni.__rawHideToast()
    return
  }
  toastState.leaving = true
  leaveTimer = setTimeout(() => {
    toastState.show = false
    toastState.leaving = false
    leaveTimer = null
  }, 180)
}

/** 接管 uni.showToast / uni.hideToast */
export function installIceToast() {
  if (typeof uni === 'undefined' || uni.__iceToastInstalled) return
  uni.__iceToastInstalled = true

  const rawShow = typeof uni.showToast === 'function' ? uni.showToast.bind(uni) : null
  const rawHide = typeof uni.hideToast === 'function' ? uni.hideToast.bind(uni) : null
  uni.__rawShowToast = rawShow
  uni.__rawHideToast = rawHide

  uni.showToast = (options = {}) => {
    try {
      showIceToast(options)
    } catch (e) {
      if (rawShow) rawShow(options)
    }
  }

  uni.hideToast = () => {
    try {
      hideIceToast()
    } catch (e) {
      if (rawHide) rawHide()
    }
  }

  uni.$iceToast = showIceToast
}
