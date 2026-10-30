Component({
  data: {
    value: 0,
    list: [
      {
        icon: 'home',
        text: '首页',
        url: 'pages/index/index'
      },
      {
        icon: 'app',
        text: '工作台',
        url: 'pages/workbench/workbench'
      },
      {
        icon: 'user',
        text: '个人中心',
        url: 'pages/usercenter/usercenter'
      }
    ]
  },
  methods: {
    onChange(event) {
      // this.setData({ value: event.detail.value })
      wx.switchTab({
        url: '/' + this.data.list[event.detail.value].url
      })
    },
    init() {
      const page = getCurrentPages().pop()
      const route = page ? page.route.split('?')[0] : ''
      const active = this.data.list.findIndex(
        (item) => (item.url.startsWith('/') ? item.url.substr(1) : item.url) === `${route}`
      )
      this.setData({ value: active })
    }
  }
})
