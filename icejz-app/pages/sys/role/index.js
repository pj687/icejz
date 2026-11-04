const cache = require('@/utils/cache.js')
const { t } = require('@/locale/index.js')
const { useRolePageApi, useRoleListApi } = require('@/api/sys.js')

Page({
  data: {
    loading: false,
    list: [],
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
        roleTitle: t('sys.roleTitle'),
        roleSub: t('sys.roleSub'),
        loadingRole: t('sys.loadingRole'),
        emptyRole: t('sys.emptyRole'),
        emptyRoleHint: t('sys.emptyRoleHint'),
        noCode: t('sys.noCode'),
        noRemark: t('sys.noRemark')
      }
    })
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
