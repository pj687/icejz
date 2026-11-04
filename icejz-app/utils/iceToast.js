const state = {
  show: false,
  leaving: false,
  title: '',
  sub: '',
  art: '',
  tone: 'info',
  iconMark: ''
}

const listeners = new Set()
let showTimer = null
let leaveTimer = null
let hostCount = 0
let installed = false

function notify() {
  const snap = { ...state }
  listeners.forEach((fn) => {
    try {
      fn(snap)
    } catch (e) {
      // ignore
    }
  })
}

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
  return 'none'
}

function subscribe(fn) {
  listeners.add(fn)
  fn({ ...state })
  return () => listeners.delete(fn)
}

function registerIceToastHost() {
  hostCount += 1
}

function unregisterIceToastHost() {
  hostCount = Math.max(0, hostCount - 1)
}

function showIceToast(options = {}) {
  const title = options.title || options.msg || ''
  if (!title) return

  const tone = resolveTone(options)
  const art = options.art || options.image || ''
  const sub = options.sub || ''
  const duration = typeof options.duration === 'number' ? options.duration : 1600

  if (hostCount <= 0 && wx.__rawShowToast) {
    wx.__rawShowToast({
      title,
      icon: resolveNativeIcon(tone, options.icon),
      duration,
      mask: !!options.mask
    })
    return
  }

  clearTimers()
  state.show = true
  state.leaving = false
  state.title = title
  state.sub = sub
  state.art = art
  state.tone = tone
  state.iconMark = resolveMark(tone, !!art)
  notify()

  showTimer = setTimeout(() => {
    state.leaving = true
    notify()
    leaveTimer = setTimeout(() => {
      state.show = false
      state.leaving = false
      showTimer = null
      leaveTimer = null
      notify()
    }, 220)
  }, duration)
}

function hideIceToast() {
  clearTimers()
  if (!state.show) {
    if (wx.__rawHideToast) wx.__rawHideToast()
    return
  }
  state.leaving = true
  notify()
  leaveTimer = setTimeout(() => {
    state.show = false
    state.leaving = false
    leaveTimer = null
    notify()
  }, 180)
}

function installIceToast() {
  if (installed) return
  installed = true

  const rawShow = typeof wx.showToast === 'function' ? wx.showToast.bind(wx) : null
  const rawHide = typeof wx.hideToast === 'function' ? wx.hideToast.bind(wx) : null
  wx.__rawShowToast = rawShow
  wx.__rawHideToast = rawHide

  wx.showToast = (options = {}) => {
    try {
      showIceToast(options)
    } catch (e) {
      if (rawShow) rawShow(options)
    }
  }

  wx.hideToast = () => {
    try {
      hideIceToast()
    } catch (e) {
      if (rawHide) rawHide()
    }
  }
}

module.exports = {
  subscribe,
  registerIceToastHost,
  unregisterIceToastHost,
  showIceToast,
  hideIceToast,
  installIceToast
}
