const cache = require('@/utils/cache.js')
const {
  useMessageMyPageApi,
  useMessageUnreadCountApi,
  useMessageMyApi,
  useMessageReadAllApi
} = require('@/api/message.js')

Page({
  data: {
    loading: false,
    list: [],
    unreadCount: 0
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.loadData()
  },

  async loadData() {
    this.setData({ loading: true })
    try {
      const [pageRes, unreadRes] = await Promise.all([
        useMessageMyPageApi({ page: 1, limit: 50 }),
        useMessageUnreadCountApi()
      ])
      this.setData({
        list: pageRes.data?.list || [],
        unreadCount: unreadRes.data || 0
      })
    } catch (e) {
      this.setData({ list: [], unreadCount: 0 })
    } finally {
      this.setData({ loading: false })
    }
  },

  async onOpen(e) {
    const id = e.currentTarget.dataset.id
    try {
      const { data } = await useMessageMyApi(id)
      wx.showModal({
        title: data?.title || '消息详情',
        content: data?.content || '无内容',
        showCancel: false
      })
      this.loadData()
    } catch (err) {
      // request 层已 toast
    }
  },

  async onReadAll() {
    try {
      await useMessageReadAllApi()
      wx.showToast({ title: '已全部已读', icon: 'none' })
      this.loadData()
    } catch (e) {
      // ignore
    }
  }
})
