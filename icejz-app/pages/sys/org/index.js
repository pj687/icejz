const cache = require('@/utils/cache.js')
const { useOrgListApi } = require('@/api/sys.js')

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
      const { data } = await useOrgListApi()
      const raw = data || []
      this.setData({ list: this.flattenTree(raw) })
    } catch (e) {
      this.setData({ list: [] })
    } finally {
      this.setData({ loading: false })
    }
  },

  flattenTree(nodes, level = 0, parentName = '') {
    const result = []
    ;(nodes || []).forEach((node) => {
      result.push({
        id: node.id,
        name: node.name,
        sort: node.sort,
        parentName,
        _level: level
      })
      if (node.children && node.children.length) {
        result.push(...this.flattenTree(node.children, level + 1, node.name))
      }
    })
    return result
  }
})
