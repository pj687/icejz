const cache = require('@/utils/cache.js')
const { useRolePageApi, useRoleListApi } = require('@/api/sys.js')

Page({
  data: {
    loading: false,
    list: []
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
      let list = []
      try {
        const pageRes = await useRolePageApi({ page: 1, limit: 100 })
        list = pageRes.data?.list || []
      } catch (e) {
        const listRes = await useRoleListApi()
        list = listRes.data || []
      }
      this.setData({ list })
    } catch (e) {
      this.setData({ list: [] })
    } finally {
      this.setData({ loading: false })
    }
  }
})
