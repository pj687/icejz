const { t } = require('@/locale/index.js')
const { markGuideDone } = require('@/utils/guide.js')

Page({
  data: {
    statusBarPx: 20,
    step: 0,
    isLast: false,
    progressText: '',
    progressPct: 25,
    steps: [],
    current: {},
    copy: {}
  },

  onLoad() {
    try {
      this.setData({ statusBarPx: wx.getSystemInfoSync().statusBarHeight || 20 })
    } catch (e) {
      this.setData({ statusBarPx: 20 })
    }
    this.refreshCopy()
  },

  onShow() {
    this.refreshCopy()
  },

  refreshCopy() {
    const steps = [
      {
        key: 'welcome',
        tone: 'cyan',
        num: '01',
        kicker: t('guide.s1Kicker'),
        title: t('guide.s1Title'),
        desc: t('guide.s1Desc'),
        chips: [t('guide.s1Chip1'), t('guide.s1Chip2'), t('guide.s1Chip3')]
      },
      {
        key: 'workbench',
        tone: 'sky',
        num: '02',
        kicker: t('guide.s2Kicker'),
        title: t('guide.s2Title'),
        desc: t('guide.s2Desc'),
        chips: [t('guide.s2Chip1'), t('guide.s2Chip2'), t('guide.s2Chip3')]
      },
      {
        key: 'assistant',
        tone: 'mint',
        num: '03',
        kicker: t('guide.s3Kicker'),
        title: t('guide.s3Title'),
        desc: t('guide.s3Desc'),
        chips: [t('guide.s3Chip1'), t('guide.s3Chip2'), t('guide.s3Chip3')]
      },
      {
        key: 'security',
        tone: 'violet',
        num: '04',
        kicker: t('guide.s4Kicker'),
        title: t('guide.s4Title'),
        desc: t('guide.s4Desc'),
        chips: [t('guide.s4Chip1'), t('guide.s4Chip2'), t('guide.s4Chip3')]
      }
    ]
    const step = this.data.step
    const total = steps.length || 1
    this.setData({
      steps,
      current: steps[step] || steps[0],
      isLast: step >= steps.length - 1,
      progressText: t('guide.stepProgress', {
        current: step + 1,
        total
      }),
      progressPct: Math.round(((step + 1) / total) * 100),
      copy: {
        skip: t('guide.skip'),
        next: t('guide.next'),
        start: t('guide.start')
      }
    })
  },

  syncStep(step) {
    const steps = this.data.steps
    const total = steps.length || 1
    this.setData({
      step,
      current: steps[step] || steps[0],
      isLast: step >= total - 1,
      progressText: t('guide.stepProgress', {
        current: step + 1,
        total
      }),
      progressPct: Math.round(((step + 1) / total) * 100)
    })
  },

  onSwipe(e) {
    this.syncStep(Number(e.detail.current) || 0)
  },

  prev() {
    if (this.data.step <= 0) return
    this.syncStep(this.data.step - 1)
  },

  next() {
    if (this.data.isLast) {
      this.finish()
      return
    }
    this.syncStep(this.data.step + 1)
  },

  finish() {
    markGuideDone()
    wx.switchTab({ url: '/pages/index/index' })
  }
})
