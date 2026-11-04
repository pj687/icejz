const GUIDE_DONE_KEY = 'icejz_guide_done'

function isGuideDone() {
  try {
    return !!wx.getStorageSync(GUIDE_DONE_KEY)
  } catch (e) {
    return false
  }
}

function markGuideDone() {
  try {
    wx.setStorageSync(GUIDE_DONE_KEY, '1')
  } catch (e) {
    // ignore
  }
}

function clearGuideDone() {
  try {
    wx.removeStorageSync(GUIDE_DONE_KEY)
  } catch (e) {
    // ignore
  }
}

function resolvePostAuthRoute() {
  return isGuideDone() ? '/pages/index/index' : '/pages/guide/guide'
}

function goAfterAuth(options = {}) {
  const { replace = true } = options
  const url = resolvePostAuthRoute()
  const isTab = url.indexOf('/pages/index/') >= 0
  if (isTab) {
    wx.switchTab({ url })
    return
  }
  if (replace) {
    wx.reLaunch({ url })
  } else {
    wx.navigateTo({ url })
  }
}

module.exports = {
  isGuideDone,
  markGuideDone,
  clearGuideDone,
  resolvePostAuthRoute,
  goAfterAuth
}
