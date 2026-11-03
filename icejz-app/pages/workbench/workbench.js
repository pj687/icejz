const cache = require('@/utils/cache.js')
const brand = require('@/config/brand.js')
const { useMessageUnreadCountApi } = require('@/api/message.js')

Page({
  data: {
    brand,
    unreadCount: 0,
    sysMenus: [
      { name: '用户管理', icon: '用', color: '#00a8e8', path: '/pages/sys/user/index' },
      { name: '机构管理', icon: '机', color: '#0c6f9c', path: '/pages/sys/org/index' },
      { name: '角色管理', icon: '角', color: '#121a28', path: '/pages/sys/role/index' }
    ],
    personalMenus: [
      { name: '我的消息', icon: '通', color: '#00a8e8', path: '/pages/message/inbox', badge: 0 },
      { name: '个人资料', icon: '资', color: '#0c6f9c', path: '/pages/usercenter/userinfo/userinfo' },
      { name: '修改密码', icon: '密', color: '#121a28', path: '/pages/usercenter/password/password' },
      { name: '关于我们', icon: '关', color: '#16a34a', path: '/pages/usercenter/about/about' }
    ]
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.getTabBar().init()
    this.loadUnread()
  },

  async loadUnread() {
    try {
      const { data } = await useMessageUnreadCountApi()
      const unread = data || 0
      const personalMenus = this.data.personalMenus.map((item) => {
        if (item.path === '/pages/message/inbox') {
          return { ...item, badge: unread > 0 ? unread : 0 }
        }
        return item
      })
      this.setData({ unreadCount: unread, personalMenus })
    } catch (e) {
      // ignore
    }
  },

  onNavigate(e) {
    const path = e.currentTarget.dataset.path
    if (!path) {
      wx.showToast({ title: '暂未开放', icon: 'none' })
      return
    }
    wx.navigateTo({ url: path })
  }
})
