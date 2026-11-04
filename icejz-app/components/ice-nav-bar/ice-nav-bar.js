Component({
  properties: {
    title: { type: String, value: '' },
    sub: { type: String, value: '' },
    showBack: { type: Boolean, value: true },
    tone: { type: String, value: 'light' }
  },
  data: {
    statusBarPx: 20,
    capsulePadPx: 96
  },
  lifetimes: {
    attached() {
      try {
        const sys = wx.getSystemInfoSync()
        const statusBarPx = sys.statusBarHeight || 20
        let capsulePadPx = 96
        try {
          const menu = wx.getMenuButtonBoundingClientRect()
          if (menu && menu.left) {
            // 右侧为微信胶囊留白；布局仍与 uniapp 一致：返回 | 标题 | 右侧操作
            capsulePadPx = Math.max(88, Math.ceil(sys.windowWidth - menu.left + 10))
          }
        } catch (e) {
          // ignore
        }
        this.setData({ statusBarPx, capsulePadPx })
      } catch (e) {
        this.setData({ statusBarPx: 20, capsulePadPx: 96 })
      }
    }
  },
  methods: {
    onBack() {
      const pages = getCurrentPages()
      if (pages.length > 1) {
        wx.navigateBack()
      } else {
        wx.switchTab({ url: '/pages/index/index' })
      }
    }
  }
})
