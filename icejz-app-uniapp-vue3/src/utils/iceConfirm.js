import { reactive } from 'vue'

export const confirmState = reactive({
  show: false,
  leaving: false,
  title: '',
  content: '',
  confirmText: '确认',
  cancelText: '取消',
  tone: 'primary',
  showCancel: true
})

let hostCount = 0
let leaveTimer = null
let resolver = null

export function registerIceConfirmHost() {
  hostCount += 1
}

export function unregisterIceConfirmHost() {
  hostCount = Math.max(0, hostCount - 1)
}

function finish(result) {
  if (leaveTimer) {
    clearTimeout(leaveTimer)
    leaveTimer = null
  }
  const resolve = resolver
  resolver = null
  confirmState.leaving = true
  leaveTimer = setTimeout(() => {
    confirmState.show = false
    confirmState.leaving = false
    leaveTimer = null
    if (resolve) resolve(result)
  }, 180)
}

export function resolveIceConfirm(confirmed) {
  if (!confirmState.show || confirmState.leaving) return
  finish(!!confirmed)
}

/**
 * 自定义确认弹窗
 * @returns {Promise<boolean>}
 */
export function showIceConfirm(options = {}) {
  const title = options.title || ''
  const content = options.content || options.message || ''

  if (hostCount <= 0 && typeof uni !== 'undefined' && typeof uni.showModal === 'function') {
    return new Promise((resolve) => {
      uni.showModal({
        title,
        content,
        showCancel: options.showCancel !== false,
        confirmText: options.confirmText || '确认',
        cancelText: options.cancelText || '取消',
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

  confirmState.show = true
  confirmState.leaving = false
  confirmState.title = title
  confirmState.content = content
  confirmState.confirmText = options.confirmText || '确认'
  confirmState.cancelText = options.cancelText || '取消'
  confirmState.tone = options.tone === 'danger' ? 'danger' : 'primary'
  confirmState.showCancel = options.showCancel !== false

  return new Promise((resolve) => {
    resolver = resolve
  })
}

export function hideIceConfirm() {
  if (!confirmState.show) return
  resolveIceConfirm(false)
}
