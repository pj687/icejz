const cache = require('@/utils/cache.js')
const brand = require('@/config/brand.js')
const { t } = require('@/locale/index.js')
const { emptyStats, fetchHomeStats } = require('@/api/stats.js')

Page({
  data: {
    brand,
    copy: {},
    statusBarPx: 20,
    capsulePadPx: 96,
    displayName: '同事',
    greeting: '你好',
    unreadCount: 0,
    unreadBadge: '0',
    msgActionHint: '',
    statsLoading: true,
    hasChartData: false,
    metrics: emptyStats().metrics,
    resourceBars: emptyStats().resourceBars,
    weekBars: emptyStats().weekBars,
    messageRing: emptyStats().messageRing,
    messageLegend: [],
    features: brand.features,
    lanes: []
  },

  onLoad() {
    try {
      const sys = wx.getSystemInfoSync()
      let capsulePadPx = 96
      try {
        const menu = wx.getMenuButtonBoundingClientRect()
        if (menu && menu.left) {
          capsulePadPx = Math.max(72, Math.ceil(sys.windowWidth - menu.left + 8))
        }
      } catch (e) {
        // ignore
      }
      this.setData({
        statusBarPx: sys.statusBarHeight || 20,
        capsulePadPx
      })
    } catch (e) {
      this.setData({ statusBarPx: 20, capsulePadPx: 96 })
    }
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().init()
    }
    this.refreshCopy()
    this.refreshUser()
    this.loadStats()
  },

  refreshCopy() {
    this.setData({
      copy: {
        enterWorkbench: t('home.enterWorkbench'),
        sysEntry: t('home.sysEntry'),
        message: t('home.message'),
        quickEntry: t('home.quickEntry'),
        resourceOverview: t('home.resourceOverview'),
        sameAsAdmin: t('home.sameAsAdmin'),
        weekMsg: t('home.weekMsg'),
        readRate: t('home.readRate'),
        read: t('home.read'),
        unread: t('home.unread'),
        boardPending: t('home.boardPending'),
        boardHint: t('home.boardHint'),
        capabilities: t('home.capabilities'),
        assistant: t('assistant.entry') || t('assistant.title')
      },
      lanes: [
        {
          key: 'user',
          name: t('stats.user'),
          hint: t('home.userHint'),
          icon: '/images/icons/user.svg',
          path: '/pages/sys/user/index'
        },
        {
          key: 'org',
          name: t('stats.org'),
          hint: t('home.orgHint'),
          icon: '/images/icons/org.svg',
          path: '/pages/sys/org/index'
        },
        {
          key: 'role',
          name: t('stats.role'),
          hint: t('home.roleHint'),
          icon: '/images/icons/role.svg',
          path: '/pages/sys/role/index'
        },
        {
          key: 'msg',
          name: t('stats.message'),
          hint: t('home.noUnread'),
          icon: '/images/icons/msg.svg',
          path: '/pages/message/inbox'
        }
      ],
      messageLegend: [
        { label: t('home.read'), value: 0, color: '#00a8e8' },
        { label: t('home.unread'), value: 0, color: '#cfeaf7' }
      ],
      msgActionHint: t('home.noUnread')
    })
  },

  refreshUser() {
    const user = cache.getUserInfo() || {}
    const h = new Date().getHours()
    let greeting = t('greet.hi')
    if (h < 6) greeting = t('greet.late')
    else if (h < 12) greeting = t('greet.morning')
    else if (h < 14) greeting = t('greet.noon')
    else if (h < 18) greeting = t('greet.afternoon')
    else greeting = t('greet.evening')

    this.setData({
      greeting,
      displayName: user.realName || user.username || t('common.user')
    })
  },

  async loadStats() {
    this.setData({ statsLoading: true })
    try {
      const data = await fetchHomeStats()
      const unread = (data.metrics.find((m) => m.key === 'msg') || {}).value || 0
      const lanes = this.data.lanes.map((item) => {
        if (item.key !== 'msg') return item
        return {
          ...item,
          hint: unread > 0 ? t('home.unreadN', { n: unread }) : t('home.noUnread')
        }
      })
      const sumBars = (data.resourceBars || []).reduce((s, i) => s + (Number(i.value) || 0), 0)
      const sumWeek = (data.weekBars || []).reduce((s, i) => s + (Number(i.value) || 0), 0)
      const hasChartData = sumBars > 0 || sumWeek > 0 || (data.messageRing && data.messageRing.total > 0)

      this.setData({
        metrics: data.metrics,
        resourceBars: data.resourceBars,
        weekBars: data.weekBars,
        messageRing: data.messageRing,
        messageLegend: [
          { label: t('home.read'), value: data.messageRing.read, color: '#00a8e8' },
          { label: t('home.unread'), value: data.messageRing.unread, color: '#cfeaf7' }
        ],
        unreadCount: unread,
        unreadBadge: unread > 99 ? '99+' : String(unread),
        msgActionHint: unread > 0 ? t('home.unreadN', { n: unread }) : t('home.noUnread'),
        lanes,
        hasChartData,
        statsLoading: false
      })
    } catch (e) {
      const empty = emptyStats()
      this.setData({
        metrics: empty.metrics,
        resourceBars: empty.resourceBars,
        weekBars: empty.weekBars,
        messageRing: empty.messageRing,
        hasChartData: false,
        statsLoading: false
      })
    }
  },

  onNav(e) {
    const { path, tab } = e.currentTarget.dataset
    if (!path) return
    if (tab === true || tab === 'true') {
      wx.switchTab({ url: path })
      return
    }
    wx.navigateTo({ url: path })
  }
})
