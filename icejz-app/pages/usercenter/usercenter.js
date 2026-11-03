const cache = require('@/utils/cache.js')
const brand = require('@/config/brand.js')
const { useLogoutApi } = require('@/api/auth.js')
const { useMessageUnreadCountApi } = require('@/api/message.js')

Page({
  data: {
    brand,
    showMakePhone: false,
    user: {
      avatar: '',
      realName: ''
    },
    menuData: [
      {
        title: '我的消息',
        icon: 'chat-message',
        count: 0,
        path: '/pages/message/inbox'
      },
      {
        title: '用户管理',
        icon: 'user',
        count: 0,
        path: '/pages/sys/user/index'
      },
      {
        title: '机构管理',
        icon: 'home',
        count: 0,
        path: '/pages/sys/org/index'
      },
      {
        title: '角色管理',
        icon: 'usergroup',
        count: 0,
        path: '/pages/sys/role/index'
      }
    ]
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.setData({ user: cache.getUserInfo() || {} })
    this.getTabBar().init()
    this.loadUnread()
  },

  async loadUnread() {
    try {
      const { data } = await useMessageUnreadCountApi()
      const count = data || 0
      const menuData = this.data.menuData.map((item) => {
        if (item.path === '/pages/message/inbox') {
          return { ...item, count }
        }
        return item
      })
      this.setData({ menuData })
    } catch (e) {
      // ignore
    }
  },

  onClickMenu(e) {
    const index = e.currentTarget.dataset.index
    const item = this.data.menuData[index]
    if (!item?.path) {
      wx.showToast({ title: '暂未开放', icon: 'none' })
      return
    }
    wx.navigateTo({ url: item.path })
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
    useLogoutApi()
      .catch(() => null)
      .finally(() => {
        cache.removeToken()
        cache.removeUserInfo()
        wx.reLaunch({ url: '/pages/login/login' })
      })
  }
})
