const cache = require('@/utils/cache.js')
const { t } = require('@/locale/index.js')
const {
  useMessageMyPageApi,
  useMessageUnreadCountApi,
  useMessageMyApi,
  useMessageReadAllApi
} = require('@/api/message.js')
const { showIceToast } = require('@/utils/iceToast.js')
const { showIceConfirm } = require('@/utils/iceConfirm.js')

Page({
  data: {
    loading: false,
    list: [],
    unreadCount: 0,
    copy: {}
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.refreshCopy()
    this.loadData()
  },

  refreshCopy() {
    this.setData({
      copy: {
        title: t('message.title'),
        sub: t('message.sub'),
        list: t('message.list'),
        readAll: t('message.readAll'),
        syncing: t('message.syncing'),
        empty: t('message.empty'),
        emptyHint: t('message.emptyHint'),
        system: t('message.system'),
        detail: t('message.detail'),
        noContent: t('message.noContent'),
        allReadOk: t('message.allReadOk')
      }
    })
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
      await showIceConfirm({
        title: data?.title || this.data.copy.detail,
        content: data?.content || this.data.copy.noContent,
        showCancel: false,
        confirmText: t('common.confirm')
      })
      this.loadData()
    } catch (err) {
      // request 层已 toast
    }
  },

  async onReadAll() {
    try {
      await useMessageReadAllApi()
      showIceToast({ title: this.data.copy.allReadOk, icon: 'success' })
      this.loadData()
    } catch (e) {
      // ignore
    }
  }
})
