const cache = require('./utils/cache.js')
const { installIceToast } = require('./utils/iceToast.js')
const { showIceConfirm } = require('./utils/iceConfirm.js')

App({
  onLaunch() {
    installIceToast()
    const token = cache.getToken()
    if (!token) {
      // 未登录时进入登录页；已登录由各页自行跳转
      const pages = getCurrentPages()
      const route = pages.length ? pages[pages.length - 1].route : ''
      if (route !== 'pages/login/login') {
        // 启动瞬间 pages 可能为空，login 已是首页之一，交由页面 onShow 守卫
      }
    }
  },
  onShow() {
    installIceToast()
    const updateManager = wx.getUpdateManager()
    updateManager.onCheckForUpdate(function () {})
    updateManager.onUpdateReady(function () {
      showIceConfirm({
        title: '更新提示',
        content: '新版本已经准备好，是否重启应用？',
        confirmText: '重启',
        cancelText: '稍后'
      }).then((ok) => {
        if (ok) updateManager.applyUpdate()
      })
    })
  },
  globalData: {}
})
