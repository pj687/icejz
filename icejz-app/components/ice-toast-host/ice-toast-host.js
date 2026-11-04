const {
  subscribe,
  registerIceToastHost,
  unregisterIceToastHost
} = require('@/utils/iceToast.js')

Component({
  data: {
    show: false,
    leaving: false,
    title: '',
    sub: '',
    art: '',
    tone: 'info'
  },
  lifetimes: {
    attached() {
      registerIceToastHost()
      this._unsub = subscribe((s) => {
        this.setData({
          show: s.show,
          leaving: s.leaving,
          title: s.title,
          sub: s.sub,
          art: s.art,
          tone: s.tone
        })
      })
    },
    detached() {
      unregisterIceToastHost()
      if (this._unsub) this._unsub()
    }
  },
  methods: {
    noop() {}
  }
})
