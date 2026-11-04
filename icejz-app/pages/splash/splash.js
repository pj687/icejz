const cache = require('@/utils/cache.js')
const { t, getLocale } = require('@/locale/index.js')
const { resolvePostAuthRoute } = require('@/utils/guide.js')

const HOLD_MS = 1500
const LEAVE_MS = 520
const PROGRESS_START_MS = 1280
const PROGRESS_DURATION_MS = 1400

function buildParticles() {
  const spots = [
    { top: '18%', left: '14%', delay: '0s', tone: 'cyan' },
    { top: '28%', left: '78%', delay: '0.6s', tone: 'soft' },
    { top: '46%', left: '12%', delay: '1.1s', tone: 'soft' },
    { top: '58%', left: '84%', delay: '0.3s', tone: 'cyan' },
    { top: '72%', left: '22%', delay: '1.4s', tone: 'soft' },
    { top: '76%', left: '68%', delay: '0.9s', tone: 'cyan' }
  ]
  return spots.map((p, i) => ({
    id: i,
    tone: p.tone,
    style: `top:${p.top};left:${p.left};animation-delay:${p.delay};`
  }))
}

Page({
  data: {
    phase: 0,
    progress: 0,
    letterStep: 0,
    ready: false,
    leaving: false,
    slogan: '',
    hint: '',
    loadingText: '',
    readyText: '',
    particles: buildParticles()
  },

  onLoad() {
    this.refreshCopy()
    this.runSequence()
  },

  onUnload() {
    this.clearTimers()
  },

  refreshCopy() {
    this.setData({
      slogan: t('splash.slogan'),
      hint: t('splash.hint'),
      loadingText: t('splash.loading'),
      readyText: getLocale() === 'en-US' ? 'Ready' : '准备就绪'
    })
  },

  clearTimers() {
    ;(this._timers || []).forEach((id) => clearTimeout(id))
    this._timers = []
    if (this._raf) {
      clearInterval(this._raf)
      this._raf = null
    }
  },

  later(fn, ms) {
    const id = setTimeout(fn, ms)
    if (!this._timers) this._timers = []
    this._timers.push(id)
    return id
  },

  runLetterReveal() {
    ;[0, 1, 2, 3, 4, 5, 6, 7, 8].forEach((step, idx) => {
      this.later(() => {
        this.setData({ letterStep: step })
      }, idx * 100)
    })
  },

  runSequence() {
    if (this._started) return
    this._started = true
    this.later(() => this.setData({ phase: 1 }), 50)
    this.later(() => {
      this.setData({ phase: 2 })
      this.runLetterReveal()
    }, 380)
    this.later(() => {
      this.setData({ phase: 3 })
      this.animateProgress()
    }, PROGRESS_START_MS)
  },

  animateProgress() {
    const start = Date.now()
    this._raf = setInterval(() => {
      const ratio = Math.min(1, (Date.now() - start) / PROGRESS_DURATION_MS)
      const eased = 1 - Math.pow(1 - ratio, 3)
      const progress = Math.round(eased * 100)
      this.setData({ progress })
      if (ratio >= 1 && this._raf) {
        clearInterval(this._raf)
        this._raf = null
        this.setData({ progress: 100 })
        this.onAllReady()
      }
    }, 32)
  },

  onAllReady() {
    if (this.data.ready) return
    this.setData({ ready: true })
    this.later(() => this.finish(), HOLD_MS)
  },

  finish() {
    if (this._done) return
    this._done = true
    this.setData({ progress: 100, leaving: true })
    this.later(() => this.goNext(), LEAVE_MS)
  },

  goNext() {
    const token = cache.getToken()
    if (!token) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    const url = resolvePostAuthRoute()
    wx.reLaunch({ url: url.includes('/pages/index/') ? '/pages/index/index' : url })
  }
})
