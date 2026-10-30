const cache = require('@/utils/cache.js')
const { useLogoutApi } = require('@/api/auth.js')

const menuData = [
  {
    title: '钱包',
    icon: 'wallet',
    count: 0
  },
  {
    title: '公司',
    icon: 'home',
    count: 0
  },
  {
    title: '客户',
    icon: 'user',
    count: 0
  },
  {
    title: '我的消息',
    icon: 'chat-message',
    count: 8
  }
]

Page({
  data: {
    showMakePhone: false,
    user: {
      avatar: '',
      realName: ''
    }
  },

  onLoad() {
    this.setData({ menuData })
  },

  onShow() {
    this.setData({ user: cache.getUserInfo() })
    this.getTabBar().init()
  },

  onClickMenu() {
    wx.showToast({
      title: '演示功能',
      icon: 'none'
    })
  },

  openMakePhone() {
    this.setData({ showMakePhone: true })
  },

  closeMakePhone() {
    this.setData({ showMakePhone: false })
  },

  onPhoneCall() {
    wx.setClipboardData({
      data: '960681673',
      success() {
        wx.showToast({
          title: 'QQ已复制：960681673',
          icon: 'none'
        })
      }
    })
  },

  onLogout() {
    useLogoutApi().then(() => {
      // 退出成功，删除token、userInfo
      cache.removeToken()
      cache.removeUserInfo()

      // 跳转到登录页
      wx.reLaunch({
        url: '/pages/login/login'
      })
    })
  }
})
