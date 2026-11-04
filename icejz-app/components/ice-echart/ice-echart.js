const echarts = require('../ec-canvas/echarts.min')

Component({
  properties: {
    option: { type: Object, value: null },
    height: { type: String, value: '280rpx' },
    canvasId: { type: String, value: 'ice-ec' }
  },
  data: {
    ec: null
  },
  lifetimes: {
    attached() {
      this._chart = null
      this._retry = 0
      this.setData({
        ec: {
          lazyLoad: true
        }
      })
      setTimeout(() => this.ensureInit(), 40)
    },
    detached() {
      if (this._chart) {
        this._chart.dispose()
        this._chart = null
      }
    }
  },
  observers: {
    option(val) {
      if (!val) return
      if (this._chart) {
        this._chart.setOption(val, true)
      } else {
        this.ensureInit()
      }
    }
  },
  methods: {
    ensureInit() {
      if (this._initing) return
      if (this._chart) {
        if (this.data.option) this._chart.setOption(this.data.option, true)
        return
      }
      const ecComponent = this.selectComponent('#' + this.data.canvasId)
      if (!ecComponent) {
        if (this._retry < 20) {
          this._retry += 1
          setTimeout(() => this.ensureInit(), 50)
        }
        return
      }
      this._initing = true
      ecComponent.init((canvas, width, height, dpr) => {
        const chart = echarts.init(canvas, null, {
          width: width || 300,
          height: height || 160,
          devicePixelRatio: dpr || 1
        })
        canvas.setChart(chart)
        if (this.data.option) {
          chart.setOption(this.data.option, true)
        }
        this._chart = chart
        this._initing = false
        return chart
      })
    }
  }
})
