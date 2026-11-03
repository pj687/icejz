const cache = require('@/utils/cache.js')
const { useUserPageApi } = require('@/api/sys.js')

Page({
  data: {
    loading: false,
    keyword: '',
    list: []
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.loadData()
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
      const { data } = await useUserPageApi({
        page: 1,
        limit: 50,
        username: this.data.keyword || undefined
      })
      const list = (data?.list || []).map((item) => {
        const name = item.realName || item.username || '?'
        return {
          ...item,
          _initial: String(name).slice(0, 1)
        }
      })
      this.setData({ list })
    } catch (e) {
      this.setData({ list: [] })
    } finally {
      this.setData({ loading: false })
    }
  }
})
