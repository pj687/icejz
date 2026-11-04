/**
 * ECharts 微信小程序 Canvas 适配层（基于 echarts-for-weixin）
 */
function WxCanvas(ctx, canvasId, isNew, canvasNode) {
  this.ctx = ctx
  this.canvasId = canvasId
  this.chart = null
  this.isNew = isNew
  if (isNew) {
    this.canvasNode = canvasNode
  } else {
    this._initStyle(ctx)
  }
  this._initEvent()
}

WxCanvas.prototype.getContext = function (contextType) {
  if (contextType === '2d') {
    return this.ctx
  }
}

WxCanvas.prototype.setChart = function (chart) {
  this.chart = chart
}

WxCanvas.prototype.addEventListener = function () {}

WxCanvas.prototype.attachEvent = function () {}

WxCanvas.prototype.detachEvent = function () {}

WxCanvas.prototype._initStyle = function (ctx) {
  ctx.createRadialGradient = function () {
    return ctx.createCircularGradient(arguments)
  }
}

WxCanvas.prototype._initEvent = function () {
  this.event = {}
  const eventNames = [
    { wxName: 'touchStart', ecName: 'mousedown' },
    { wxName: 'touchMove', ecName: 'mousemove' },
    { wxName: 'touchEnd', ecName: 'mouseup' },
    { wxName: 'touchEnd', ecName: 'click' }
  ]
  eventNames.forEach((name) => {
    this.event[name.wxName] = (e) => {
      const touch = e.touches[0]
      this.chart.getZr().handler.dispatch(name.ecName, {
        zrX: name.wxName === 'tap' ? touch.clientX : touch.x,
        zrY: name.wxName === 'tap' ? touch.clientY : touch.y,
        preventDefault() {},
        stopImmediatePropagation() {},
        stopPropagation() {}
      })
    }
  })
}

Object.defineProperty(WxCanvas.prototype, 'width', {
  get() {
    return (this.canvasNode && this.canvasNode.width) || 0
  },
  set(w) {
    if (this.canvasNode) this.canvasNode.width = w
  }
})

Object.defineProperty(WxCanvas.prototype, 'height', {
  get() {
    return (this.canvasNode && this.canvasNode.height) || 0
  },
  set(h) {
    if (this.canvasNode) this.canvasNode.height = h
  }
})

module.exports = WxCanvas
