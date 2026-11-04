const state = {
  show: false,
  leaving: false,
  title: '',
  content: '',
  confirmText: '确认',
  cancelText: '取消',
  tone: 'primary',
  showCancel: true
}

const listeners = new Set()
let hostCount = 0
let leaveTimer = null
let resolver = null

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

function subscribe(fn) {
  listeners.add(fn)
  fn({ ...state })
  return () => listeners.delete(fn)
}

function registerIceConfirmHost() {
  hostCount += 1
}

function unregisterIceConfirmHost() {
  hostCount = Math.max(0, hostCount - 1)
}

function finish(result) {
  if (leaveTimer) {
    clearTimeout(leaveTimer)
    leaveTimer = null
  }
  const resolve = resolver
  resolver = null
  state.leaving = true
  notify()
  leaveTimer = setTimeout(() => {
    state.show = false
    state.leaving = false
    leaveTimer = null
    notify()
    if (resolve) resolve(result)
  }, 180)
}

function resolveIceConfirm(confirmed) {
  if (!state.show || state.leaving) return
  finish(!!confirmed)
}

/**
 * @returns {Promise<boolean>}
 */
function showIceConfirm(options = {}) {
  const title = options.title || ''
  const content = options.content || options.message || ''

  if (hostCount <= 0) {
    return new Promise((resolve) => {
      wx.showModal({
        title,
        content,
        showCancel: options.showCancel !== false,
        confirmText: options.confirmText || '确认',
        cancelText: options.cancelText || '取消',
        confirmColor: options.tone === 'danger' ? '#e11d48' : '#00a8e8',
        success: (res) => resolve(!!res.confirm),
        fail: () => resolve(false)
      })
    })
  }

  if (resolver) {
    const prev = resolver
    resolver = null
    prev(false)
  }

  if (leaveTimer) {
    clearTimeout(leaveTimer)
    leaveTimer = null
  }

  state.show = true
  state.leaving = false
  state.title = title
  state.content = content
  state.confirmText = options.confirmText || '确认'
  state.cancelText = options.cancelText || '取消'
  state.tone = options.tone === 'danger' ? 'danger' : 'primary'
  state.showCancel = options.showCancel !== false
  notify()

  return new Promise((resolve) => {
    resolver = resolve
  })
}

function hideIceConfirm() {
  if (!state.show) return
  resolveIceConfirm(false)
}

module.exports = {
  subscribe,
  registerIceConfirmHost,
  unregisterIceConfirmHost,
  resolveIceConfirm,
  showIceConfirm,
  hideIceConfirm
}
