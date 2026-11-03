const cache = require('@/utils/cache.js')
const brand = require('@/config/brand.js')
const { useMessageUnreadCountApi } = require('@/api/message.js')

Page({
  data: {
    brand,
    displayName: '同事',
    greeting: '你好',
    unreadCount: 0,
    features: brand.features
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.getTabBar().init()
    this.refreshUser()
    this.loadUnread()
  },

  refreshUser() {
    const user = cache.getUserInfo() || {}
    const h = new Date().getHours()
    let greeting = '你好'
    if (h < 6) greeting = '夜深了'
    else if (h < 12) greeting = '早上好'
    else if (h < 14) greeting = '中午好'
    else if (h < 18) greeting = '下午好'
    else greeting = '晚上好'

    this.setData({
      greeting,
      displayName: user.realName || user.username || '同事'
    })
  },

  async loadUnread() {
    try {
      const { data } = await useMessageUnreadCountApi()
      this.setData({ unreadCount: data || 0 })
    } catch (e) {
      this.setData({ unreadCount: 0 })
    }
  },

  onQuickTap(e) {
    const { path, tab } = e.currentTarget.dataset
    if (!path) return
    if (tab === true || tab === 'true') {
      wx.switchTab({ url: path })
      return
    }
    wx.navigateTo({ url: path })
  }
})
