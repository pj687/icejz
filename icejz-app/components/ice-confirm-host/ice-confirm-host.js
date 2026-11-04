const {
  subscribe,
  registerIceConfirmHost,
  unregisterIceConfirmHost,
  resolveIceConfirm
} = require('@/utils/iceConfirm.js')

Component({
  data: {
    show: false,
    leaving: false,
    title: '',
    content: '',
    confirmText: '确认',
    cancelText: '取消',
    tone: 'primary',
    showCancel: true
  },
  lifetimes: {
    attached() {
      registerIceConfirmHost()
      this._unsub = subscribe((s) => {
        this.setData({
          show: s.show,
          leaving: s.leaving,
          title: s.title,
          content: s.content,
          confirmText: s.confirmText,
          cancelText: s.cancelText,
          tone: s.tone,
          showCancel: s.showCancel
        })
      })
    },
    detached() {
      unregisterIceConfirmHost()
      if (this._unsub) this._unsub()
    }
  },
  methods: {
    noop() {},
    onCancel() {
      resolveIceConfirm(false)
    },
    onConfirm() {
      resolveIceConfirm(true)
    }
  }
})
