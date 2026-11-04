const cache = require('@/utils/cache.js')
const { t } = require('@/locale/index.js')
const { useUserPageApi } = require('@/api/sys.js')

function normalizeUserList(payload) {
  if (!payload) return []
  if (Array.isArray(payload)) return payload
  if (Array.isArray(payload.list)) return payload.list
  if (Array.isArray(payload.records)) return payload.records
  return []
}

Page({
  data: {
    loading: false,
    keyword: '',
    list: [],
    total: 0,
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
        userTitle: t('sys.userTitle'),
        userSub: t('sys.userSub'),
        searchUsername: t('sys.searchUsername'),
        search: t('common.search'),
        loadingUser: t('sys.loadingUser'),
        emptyUser: t('sys.emptyUser'),
        emptyUserHint: t('sys.emptyUserHint'),
        mobile: t('sys.mobile'),
        email: t('sys.email'),
        normal: t('sys.normal'),
        disabled: t('sys.disabled')
      }
    })
  },

  onKeyword(e) {
    this.setData({ keyword: e.detail.value })
  },

  onSearch() {
    this.loadData()
  },

  async loadData() {
    this.setData({ loading: true })
    try {
      const params = {
        page: 1,
        limit: 50
      }
      const keyword = String(this.data.keyword || '').trim()
      if (keyword) params.username = keyword

      const res = await useUserPageApi(params)
      const raw = normalizeUserList(res && res.data)
      const list = raw.map((item) => {
        const name = item.realName || item.username || '?'
        return {
          ...item,
          _initial: String(name).slice(0, 1),
          _on: Number(item.status) === 1
        }
      })
      this.setData({
        list,
        total: Number((res && res.data && res.data.total) || list.length) || 0
      })
    } catch (e) {
      this.setData({ list: [], total: 0 })
      wx.showToast({
        title: (e && e.msg) || t('sys.emptyUserHint'),
        icon: 'none'
      })
    } finally {
      this.setData({ loading: false })
    }
  }
})
