const { t } = require('@/locale/index.js')

Component({
  data: {
    value: 0,
    hidden: false,
    // 对齐 uniapp：指示条左右各约 1.2%，宽度平分三栏
    indicatorLeft: 1.2,
    indicatorWidth: 31.333,
    list: []
  },
  lifetimes: {
    attached() {
      this.refreshLocale()
    }
  },
  pageLifetimes: {
    show() {
      this.refreshLocale()
    }
  },
  methods: {
    refreshLocale() {
      this.setData({
        list: [
          {
            text: t('tab.home'),
            url: 'pages/index/index',
            icon: '/images/tab/home.svg',
            activeIcon: '/images/tab/home-active.svg'
          },
          {
            text: t('tab.workbench'),
            url: 'pages/workbench/workbench',
            icon: '/images/tab/work.svg',
            activeIcon: '/images/tab/work-active.svg'
          },
          {
            text: t('tab.mine'),
            url: 'pages/usercenter/usercenter',
            icon: '/images/tab/me.svg',
            activeIcon: '/images/tab/me-active.svg'
          }
        ]
      })
    },
    indicatorPos(index) {
      const n = this.data.list.length || 3
      const inset = 1.2
      const width = (100 - inset * 2) / n
      return {
        indicatorLeft: inset + index * width,
        indicatorWidth: width
      }
    },
    onChange(e) {
      const index = Number(e.currentTarget.dataset.index)
      if (Number.isNaN(index) || index === this.data.value) return
      this.setData({
        value: index,
        ...this.indicatorPos(index)
      })
      wx.switchTab({
        url: '/' + this.data.list[index].url
      })
    },
    init() {
      this.refreshLocale()
      const pages = getCurrentPages()
      const page = pages[pages.length - 1]
      const route = page ? page.route.split('?')[0] : ''
      const active = this.data.list.findIndex(
        (item) => (item.url.startsWith('/') ? item.url.slice(1) : item.url) === route
      )
      const value = active >= 0 ? active : 0
      this.setData({
        value,
        hidden: false,
        ...this.indicatorPos(value)
      })
    }
  }
})
