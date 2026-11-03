const PUZZLE_W = 310
const PIECE = 42
const SLIDER_MAX = PUZZLE_W - PIECE // 268

Component({
  properties: {
    mode: { type: String, value: 'input' },
    tip: { type: String, value: '' },
    image: { type: String, value: '' },
    jigsawImage: { type: String, value: '' },
    jigsawY: { type: Number, value: 0 },
    words: { type: Array, value: [] },
    value: { type: String, value: '' }
  },
  data: {
    visible: false,
    localValue: '',
    committed: '',
    verified: false,
    verifiedText: '',
    canConfirm: false,
    confirmHint: '请先完成验证',
    sliderX: 0,
    pieceLeftPercent: 0,
    trackPercent: 0,
    jigsawTopPercent: 0,
    wordClicks: [],
    wordNeed: 3,
    localIndexDisplay: 1
  },
  observers: {
    value(v) {
      if (v === '' || v == null) {
        this.setData({
          committed: '',
          verified: false,
          localValue: '',
          canConfirm: false
        })
        this.updateHints()
      }
    },
    image() {
      if (this.data.visible) {
        this.setData({
          localValue: '',
          canConfirm: false,
          sliderX: 0,
          pieceLeftPercent: 0,
          trackPercent: 0,
          wordClicks: [],
          localIndexDisplay: 1
        })
        this.updateHints()
      }
    },
    'jigsawY, words, mode'() {
      this.setData({
        jigsawTopPercent: ((this.data.jigsawY || 0) / 155) * 100,
        wordNeed: (this.data.words && this.data.words.length) || 3
      })
      this.updateHints()
    },
    localValue(v) {
      const ok = v !== '' && v != null
      this.setData({ canConfirm: ok })
      const mode = this.data.mode
      if (!this.data.visible) return
      if (ok && ['click', 'slider', 'word'].includes(mode)) {
        clearTimeout(this._autoTimer)
        this._autoTimer = setTimeout(() => {
          if (this.data.localValue !== '' && this.data.localValue != null) {
            this.confirm()
          }
        }, 280)
      }
    }
  },
  lifetimes: {
    detached() {
      clearTimeout(this._autoTimer)
    }
  },
  methods: {
    noop() {},
    updateHints() {
      const mode = this.data.mode
      const committed = this.data.committed
      let verifiedText = '图形验证已通过'
      if (mode === 'click') verifiedText = '已选择图案'
      else if (mode === 'slider') verifiedText = '滑动拼图已完成'
      else if (mode === 'word') verifiedText = '文字点选已完成'

      let confirmHint = '请先填写验证码'
      if (mode === 'click') confirmHint = '请先点选图案'
      else if (mode === 'slider') confirmHint = '请先完成拼图'
      else if (mode === 'word') confirmHint = '请先点选文字'
      else if (mode === 'pow' || mode === 'turnstile') confirmHint = '请更换验证码类型'

      this.setData({
        verifiedText,
        confirmHint,
        verified: committed !== '' && committed != null
      })
    },
    setSliderX(x) {
      const sliderX = Math.min(SLIDER_MAX, Math.max(0, Math.round(x)))
      this.setData({
        sliderX,
        pieceLeftPercent: (sliderX / PUZZLE_W) * 100,
        trackPercent: (sliderX / SLIDER_MAX) * 100
      })
    },
    open() {
      this.setData({
        visible: true,
        localValue: '',
        canConfirm: false,
        sliderX: 0,
        pieceLeftPercent: 0,
        trackPercent: 0,
        wordClicks: [],
        localIndexDisplay: 1,
        jigsawTopPercent: ((this.data.jigsawY || 0) / 155) * 100,
        wordNeed: (this.data.words && this.data.words.length) || 3
      })
      this.updateHints()
      this.triggerEvent('refresh')
    },
    close() {
      this.setData({ visible: false, localValue: '', canConfirm: false })
    },
    onRefresh() {
      this.setData({
        localValue: '',
        canConfirm: false,
        sliderX: 0,
        pieceLeftPercent: 0,
        trackPercent: 0,
        wordClicks: [],
        localIndexDisplay: 1
      })
      this.triggerEvent('refresh')
    },
    confirm() {
      if (!this.data.canConfirm) return
      const committed = String(this.data.localValue)
      this.setData({
        committed,
        verified: true,
        visible: false,
        localValue: ''
      })
      this.updateHints()
      this.triggerEvent('confirm', { value: committed })
      this.triggerEvent('change', { value: committed })
    },
    reset() {
      this.setData({
        committed: '',
        verified: false,
        localValue: '',
        canConfirm: false,
        visible: false
      })
      this.updateHints()
      this.triggerEvent('change', { value: '' })
    },
    ensure() {
      if (this.data.verified && this.data.committed !== '') return true
      this.open()
      return false
    },
    onInput(e) {
      this.setData({ localValue: e.detail.value || '' })
    },
    measureTrack(cb) {
      wx.createSelectorQuery()
        .in(this)
        .select('.slider-track')
        .boundingClientRect((rect) => {
          if (rect && rect.width) {
            this._trackLeft = rect.left
            this._trackWidth = rect.width
          }
          cb && cb()
        })
        .exec()
    },
    applyClientX(clientX) {
      const left = this._trackLeft || 0
      const width = this._trackWidth || 1
      const ratio = Math.min(1, Math.max(0, (clientX - left) / width))
      this.setSliderX(ratio * SLIDER_MAX)
    },
    onTrackStart(e) {
      this._dragging = true
      const t = e.touches && e.touches[0]
      this.measureTrack(() => {
        if (t) this.applyClientX(t.clientX)
      })
    },
    onTrackMove(e) {
      if (!this._dragging) return
      const t = e.touches && e.touches[0]
      if (t) this.applyClientX(t.clientX)
    },
    onTrackEnd() {
      if (!this._dragging) return
      this._dragging = false
      this.setData({
        localValue: String(this.data.sliderX),
        canConfirm: true
      })
    },
    onPatternTap(e) {
      wx.createSelectorQuery()
        .in(this)
        .select('.pattern-box-inner.clickable')
        .boundingClientRect((rect) => {
          if (!rect || !rect.width) {
            this.onRefresh()
            return
          }
          const clientX = e?.detail?.x ?? e?.touches?.[0]?.clientX ?? 0
          const clientY = e?.detail?.y ?? e?.touches?.[0]?.clientY ?? 0
          const relX = clientX - rect.left
          const relY = clientY - rect.top
          const x = Math.round((relX / rect.width) * 310)
          const y = Math.round((relY / Math.max(1, rect.height)) * 155)
          this.setData({
            localValue: `${x},${y}`,
            localIndexDisplay: 1,
            canConfirm: true
          })
        })
        .exec()
    },
    onWordTap(e) {
      const need = this.data.wordNeed || 3
      wx.createSelectorQuery()
        .in(this)
        .select('.pattern-box-inner')
        .boundingClientRect((rect) => {
          if (!rect || !rect.width) return
          const clientX = e?.detail?.x ?? e?.touches?.[0]?.clientX ?? 0
          const clientY = e?.detail?.y ?? e?.touches?.[0]?.clientY ?? 0
          const relX = clientX - rect.left
          const relY = clientY - rect.top
          const x = Math.round((relX / rect.width) * 310)
          const y = Math.round((relY / rect.height) * 155)
          let clicks = this.data.wordClicks.slice()
          if (clicks.length >= need) clicks = []
          clicks.push(`${x},${y}`)
          const done = clicks.length >= need
          this.setData({
            wordClicks: clicks,
            localValue: done ? clicks.join('|') : '',
            canConfirm: done
          })
        })
        .exec()
    }
  }
})
