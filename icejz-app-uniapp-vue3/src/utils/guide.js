const GUIDE_DONE_KEY = 'icejz_guide_done'

export function isGuideDone() {
  try {
    return !!uni.getStorageSync(GUIDE_DONE_KEY)
  } catch (e) {
    return false
  }
}

export function markGuideDone() {
  try {
    uni.setStorageSync(GUIDE_DONE_KEY, '1')
  } catch (e) {
    // ignore
  }
}

export function clearGuideDone() {
  try {
    uni.removeStorageSync(GUIDE_DONE_KEY)
  } catch (e) {
    // ignore
  }
}

/** 登录/启动后进入首页前的路由决策 */
export function resolvePostAuthRoute() {
  return isGuideDone() ? '/pages/index/index' : '/pages/guide/guide'
}

export function goAfterAuth(options = {}) {
  const { replace = true } = options
  const url = resolvePostAuthRoute()
  const isTab = url.includes('/pages/index/')
  if (isTab) {
    uni.switchTab({ url })
    return
  }
  if (replace) {
    uni.reLaunch({ url })
  } else {
    uni.navigateTo({ url })
  }
}
