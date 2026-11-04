const cache = require('@/utils/cache.js')
const { t } = require('@/locale/index.js')
const { useOrgListApi } = require('@/api/sys.js')

Page({
  data: {
    loading: false,
    flatList: [],
    visibleList: [],
    expanded: {},
    nodeCount: 0,
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
        orgTitle: t('sys.orgTitle'),
        orgSub: t('sys.orgSub'),
        loadingOrg: t('sys.loadingOrg'),
        emptyOrg: t('sys.emptyOrg'),
        topOrg: t('sys.topOrg'),
        sort: t('sys.sort'),
        expandAll: t('sys.expandAll'),
        collapseAll: t('sys.collapseAll')
      }
    })
  },

  async loadData() {
    this.setData({ loading: true })
    try {
      const { data } = await useOrgListApi()
      const flatList = this.flattenTree(data || [])
      const expanded = {}
      flatList.forEach((item) => {
        if (item._hasChildren) expanded[item.id] = true
      })
      this.setData({
        flatList,
        expanded,
        nodeCount: flatList.length
      })
      this.refreshVisible()
    } catch (e) {
      this.setData({ flatList: [], visibleList: [], expanded: {}, nodeCount: 0 })
      wx.showToast({
        title: (e && e.msg) || t('sys.emptyOrg'),
        icon: 'none'
      })
    } finally {
      this.setData({ loading: false })
    }
  },

  flattenTree(nodes, level = 0, parentId = null, parentName = '') {
    const result = []
    const list = nodes || []
    list.forEach((node, index) => {
      const children = node.children || []
      const hasChildren = children.length > 0
      result.push({
        id: node.id,
        name: node.name,
        sort: node.sort,
        parentName,
        parentId,
        _level: level,
        _last: index === list.length - 1,
        _hasChildren: hasChildren,
        _childCount: children.length
      })
      if (hasChildren) {
        result.push(...this.flattenTree(children, level + 1, node.id, node.name))
      }
    })
    return result
  },

  refreshVisible() {
    const expanded = this.data.expanded || {}
    const visible = []
    const openAncestors = { null: true, undefined: true }
    this.data.flatList.forEach((item) => {
      const parentOpen = openAncestors[item.parentId]
      if (!parentOpen) return
      visible.push({
        ...item,
        _expanded: !!expanded[item.id]
      })
      openAncestors[item.id] = !!expanded[item.id]
    })
    this.setData({ visibleList: visible })
  },

  onToggle(e) {
    const id = e.currentTarget.dataset.id
    const hasChildren = e.currentTarget.dataset.hasChildren
    // dataset 会把布尔转成字符串，"false" 也是 truthy
    if (hasChildren !== true && hasChildren !== 'true') return
    const key = 'expanded.' + id
    this.setData({
      [key]: !this.data.expanded[id]
    }, () => this.refreshVisible())
  },

  expandAll() {
    const expanded = {}
    this.data.flatList.forEach((item) => {
      if (item._hasChildren) expanded[item.id] = true
    })
    this.setData({ expanded }, () => this.refreshVisible())
  },

  collapseAll() {
    this.setData({ expanded: {} }, () => this.refreshVisible())
  }
})
