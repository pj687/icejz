const { useCaptchaCheckApi } = require('@/api/auth.js')

const PUZZLE_W = 310
const PUZZLE_H = 155
const PIECE = 42
const PIECE_CANVAS = PIECE + Math.max(6, Math.floor(PIECE / 5))
const PIECE_W_PERCENT = (PIECE_CANVAS / PUZZLE_W) * 100
const PIECE_H_PERCENT = (PIECE_CANVAS / PUZZLE_H) * 100

function parseCurveMeta(list) {
  if (!list || list.length < 4) return null
  const left = String(list[0]).split(',')
  const right = String(list[1]).split(',')
  const deepY = Number(list[2])
  const rest = String(list[3]).split(',')
  const leftX = Number(left[0])
  const leftY = Number(left[1])
  const rightX = Number(right[0])
  const rightY = Number(right[1])
  const vertexBase = Number(rest[0])
  const travel = Number(rest[1])
  if (![leftX, leftY, rightX, rightY, deepY, vertexBase, travel].every(Number.isFinite)) return null
  return { leftX, leftY, rightX, rightY, deepY, vertexBase, travel }
}

function sliderMaxFor(mode, words) {
  if (mode === 'curve') {
    const meta = parseCurveMeta(words)
    if (meta) return Math.max(1, meta.travel)
  }
  return PUZZLE_W - PIECE
}

/** 两端绝对固定，仅中点 vx 随滑块移动（与后端 buildVRopePath 同公式） */
function strokeVRope(ctx, lx, ly, vx, vy, rx, ry) {
  const c1x = lx + (vx - lx) * 0.3
  const c1y = ly + (vy - ly) * 0.68
  const c2x = vx - (vx - lx) * 0.36
  const c2y = vy - (vy - ly) * 0.04
  const c3x = vx + (rx - vx) * 0.36
  const c3y = vy - (vy - ry) * 0.04
  const c4x = rx - (rx - vx) * 0.3
  const c4y = ry + (vy - ry) * 0.68
  ctx.beginPath()
  ctx.moveTo(lx, ly)
  ctx.bezierCurveTo(c1x, c1y, c2x, c2y, vx, vy)
  ctx.bezierCurveTo(c3x, c3y, c4x, c4y, rx, ry)
}

Component({
  properties: {
    captchaKey: { type: String, value: '' },
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
    footBtnText: '请先完成验证',
    status: 'idle', // idle | ok | fail
    checking: false,
    statusHint: '',
    sliderX: 0,
    dragging: false,
    pieceLeftPercent: 0,
    pieceWidthPercent: PIECE_W_PERCENT,
    pieceHeightPercent: PIECE_H_PERCENT,
    trackPercent: 0,
    jigsawTopPercent: 0,
    rotateDeg: 0,
    showCurveRope: false,
    ropeCanvasCss: '',
    wordClicks: [],
    wordMarks: [],
    wordNeed: 3,
    patternMark: null,
    markText: '✓',
    triggerHint: '点击完成图形验证'
  },
  observers: {
    value(v) {
      // 仅在外部清空「已通过」的值时重置；失败态不要被空 value 冲掉
      if (v === '' || v == null) {
        if (!this.data.verified && this.data.committed === '') return
        if (this.data.status === 'fail' || this.data.checking) return
        this.setData({
          committed: '',
          verified: false,
          localValue: '',
          canConfirm: false,
          status: 'idle'
        })
        this.updateHints()
      }
    },
    image() {
      if (this.data.visible && this.data.status !== 'fail') {
        this.resetInteraction(false)
      }
    },
    'jigsawY, words, mode'() {
      this.applyModeLayout(0)
      this.setData({
        wordNeed: (this.data.words && this.data.words.length) || 3
      })
      this.updateHints()
    }
  },
  lifetimes: {
    detached() {
      clearTimeout(this._autoTimer)
      clearTimeout(this._failTimer)
    }
  },
  methods: {
    noop() {},
    isInteractiveMode(mode) {
      return mode === 'click' || mode === 'slider' || mode === 'word'
        || mode === 'curve' || mode === 'rotate' || mode === 'angle'
    },
    applyModeLayout(sliderX) {
      const mode = this.data.mode
      const max = sliderMaxFor(mode, this.data.words)
      if (mode === 'curve') {
        this.setData({
          sliderX,
          trackPercent: (sliderX / max) * 100,
          rotateDeg: 0,
          pieceLeftPercent: 0,
          jigsawTopPercent: 0,
          showCurveRope: true
        })
        this.scheduleCurveRope(sliderX)
        return
      }
      if (mode === 'rotate' || mode === 'angle') {
        const rotateDeg = Math.round((sliderX / max) * 360)
        this.setData({
          sliderX,
          trackPercent: (sliderX / max) * 100,
          rotateDeg,
          pieceLeftPercent: 0,
          jigsawTopPercent: 0,
          showCurveRope: false
        })
        return
      }
      this.setData({
        sliderX,
        pieceLeftPercent: (sliderX / PUZZLE_W) * 100,
        jigsawTopPercent: ((this.data.jigsawY || 0) / PUZZLE_H) * 100,
        trackPercent: (sliderX / max) * 100,
        pieceWidthPercent: PIECE_W_PERCENT,
        pieceHeightPercent: PIECE_H_PERCENT,
        rotateDeg: 0,
        showCurveRope: false
      })
    },
    onPuzzleImgLoad() {
      if (this.data.mode === 'curve') {
        this.scheduleCurveRope(this.data.sliderX || 0)
      }
    },
    scheduleCurveRope(sliderX) {
      this._ropeSliderX = sliderX
      if (this._ropeRaf) return
      this._ropeRaf = true
      setTimeout(() => {
        this._ropeRaf = false
        this.drawCurveRope(this._ropeSliderX)
      }, 16)
    },
    drawCurveRope(sliderX, retry) {
      const meta = parseCurveMeta(this.data.words)
      if (!meta) return
      const max = Math.max(1, meta.travel)
      const ox = Math.min(max, Math.max(0, sliderX))
      const vx = meta.vertexBase + ox
      const vy = meta.deepY
      const query = wx.createSelectorQuery().in(this)
      // 必须按底图像素框对齐，不能用 wrap（可能被 min-height 撑高导致端点错位）
      query.select('.puzzle-wrap').boundingClientRect()
      query.select('.pattern-img').boundingClientRect()
      query.select('#curveRope').fields({ node: true, size: true })
      query.exec((res) => {
        const wrap = res && res[0]
        const img = res && res[1]
        const entry = res && res[2]
        const width = img && img.width
        const height = img && img.height
        if (!wrap || !img || !width || !height || !entry || !entry.node) {
          const n = typeof retry === 'number' ? retry : 0
          if (n < 8) setTimeout(() => this.drawCurveRope(sliderX, n + 1), 40 + n * 20)
          return
        }
        const left = Math.round(img.left - wrap.left)
        const top = Math.round(img.top - wrap.top)
        const css =
          'left:' + left + 'px;top:' + top + 'px;width:' + width + 'px;height:' + height + 'px;'
        const paint = () => {
          const canvas = entry.node
          let dpr = 1
          try {
            dpr = (wx.getWindowInfo && wx.getWindowInfo().pixelRatio) || wx.getSystemInfoSync().pixelRatio || 1
          } catch (e) {
            dpr = 1
          }
          canvas.width = Math.max(1, Math.floor(width * dpr))
          canvas.height = Math.max(1, Math.floor(height * dpr))
          const ctx = canvas.getContext('2d')
          ctx.setTransform(1, 0, 0, 1, 0, 0)
          ctx.clearRect(0, 0, canvas.width, canvas.height)
          // 逻辑坐标与后端 CaptchaGenerator（PUZZLE_W×PUZZLE_H）一一对应
          ctx.setTransform((dpr * width) / PUZZLE_W, 0, 0, (dpr * height) / PUZZLE_H, 0, 0)
          ctx.lineCap = 'round'
          ctx.lineJoin = 'round'
          ctx.strokeStyle = 'rgba(255,255,255,0.32)'
          ctx.lineWidth = 13
          strokeVRope(ctx, meta.leftX, meta.leftY, vx, vy, meta.rightX, meta.rightY)
          ctx.stroke()
          ctx.strokeStyle = '#ffffff'
          ctx.lineWidth = 5.5
          strokeVRope(ctx, meta.leftX, meta.leftY, vx, vy, meta.rightX, meta.rightY)
          ctx.stroke()
          ctx.beginPath()
          ctx.fillStyle = '#ffffff'
          ctx.strokeStyle = '#00a8e8'
          ctx.lineWidth = 2.4
          ctx.arc(vx, vy, 6.5, 0, Math.PI * 2)
          ctx.fill()
          ctx.stroke()
        }
        if (this.data.ropeCanvasCss !== css) {
          this.setData({ ropeCanvasCss: css }, paint)
        } else {
          paint()
        }
      })
    },
    updateHints() {
      const mode = this.data.mode
      const committed = this.data.committed
      let verifiedText = '图形验证已通过'
      let triggerHint = '点击完成图形验证'
      if (mode === 'click') {
        verifiedText = '图案点选已通过'
        triggerHint = '点击完成图案点选'
      } else if (mode === 'slider') {
        verifiedText = '滑动拼图已通过'
        triggerHint = '点击完成滑动拼图'
      } else if (mode === 'curve') {
        verifiedText = '滑动曲线已通过'
        triggerHint = '点击完成滑动曲线'
      } else if (mode === 'rotate') {
        verifiedText = '旋转验证已通过'
        triggerHint = '点击完成旋转验证'
      } else if (mode === 'angle') {
        verifiedText = '角度验证已通过'
        triggerHint = '点击完成角度验证'
      } else if (mode === 'word') {
        verifiedText = '文字点选已通过'
        triggerHint = '点击完成文字点选'
      } else if (mode === 'pow') {
        verifiedText = '算力校验已通过'
        triggerHint = '当前端不支持算力校验'
      } else if (mode === 'turnstile') {
        verifiedText = '人机验证已通过'
        triggerHint = '当前端不支持 Turnstile'
      } else {
        triggerHint = '点击输入图形验证码'
      }

      let confirmHint = '请先填写验证码'
      if (mode === 'click') confirmHint = '请先点选正确图案'
      else if (mode === 'curve') confirmHint = '请先拖动滑块摆动绳子使中点对齐'
      else if (mode === 'slider') confirmHint = '请先拖动滑块对齐'
      else if (mode === 'rotate' || mode === 'angle') confirmHint = '请先旋转到正确角度'
      else if (mode === 'word') confirmHint = '请按顺序点选文字'
      else if (mode === 'pow' || mode === 'turnstile') confirmHint = '请更换验证码类型'

      const canConfirm = this.computeCanConfirm()
      this.setData({
        verifiedText,
        triggerHint,
        confirmHint,
        canConfirm,
        footBtnText: this.buildFootBtnText(canConfirm, confirmHint),
        verified: committed !== '' && committed != null,
        statusHint: this.buildStatusHint({
          status: this.data.status,
          checking: this.data.checking,
          wordClicks: this.data.wordClicks,
          wordNeed: this.data.wordNeed,
          localValue: this.data.localValue
        })
      })
    },
    computeCanConfirm() {
      const { mode, checking, localValue, status } = this.data
      if (checking) return false
      if (localValue === '' || localValue == null) return false
      if (this.isInteractiveMode(mode)) return status === 'ok'
      if (mode === 'pow' || mode === 'turnstile') return false
      return true
    },
    buildFootBtnText(canConfirm, confirmHint) {
      if (this.data.checking) return '校验中…'
      if (!canConfirm) return confirmHint || this.data.confirmHint
      if (this.data.status === 'ok' || this.isInteractiveMode(this.data.mode)) return '验证通过'
      return '确认验证'
    },
    buildStatusHint(patch = {}) {
      const mode = patch.mode != null ? patch.mode : this.data.mode
      const status = patch.status != null ? patch.status : this.data.status
      const checking = patch.checking != null ? patch.checking : this.data.checking
      const wordClicks = patch.wordClicks != null ? patch.wordClicks : this.data.wordClicks
      const wordNeed = patch.wordNeed != null ? patch.wordNeed : this.data.wordNeed
      const localValue = patch.localValue != null ? patch.localValue : this.data.localValue
      if (mode === 'click') {
        if (checking) return '正在校验图案…'
        if (status === 'ok') return '验证通过，可继续'
        if (status === 'fail') return '选择错误，正在换一张…'
        return '点击正确图案后才会通过验证'
      }
      if (mode === 'word') {
        if (checking) return '正在校验点选…'
        if (status === 'ok') return '验证通过，可继续'
        if (status === 'fail') return '点选错误，正在换一张…'
        return `已点 ${(wordClicks && wordClicks.length) || 0}/${wordNeed || 3}，按提示依次点击`
      }
      if (mode === 'slider' || mode === 'curve') {
        if (checking) return '正在校验…'
        if (status === 'ok') return mode === 'curve' ? '绳子已对齐，可继续' : '拼图已对齐，可继续'
        if (status === 'fail') return '未对齐，正在换一张…'
        return mode === 'curve'
          ? '两端已固定在底图端点，拖动滑块摆动中点对齐'
          : (localValue !== '' ? '拼图完成' : '拖动滑块，使拼图块嵌入缺口')
      }
      if (mode === 'rotate' || mode === 'angle') {
        if (checking) return '正在校验角度…'
        if (status === 'ok') return '角度正确，可继续'
        if (status === 'fail') return '角度错误，正在换一张…'
        return mode === 'angle' ? '拖动滑块，将指针旋至正上方' : '拖动滑块，将图片旋转至正向'
      }
      if (mode === 'pow' || mode === 'turnstile') {
        return '请在管理端将该端验证码改为点选 / 拼图 / 曲线 / 旋转 / 输入型'
      }
      return '看不清可点右侧图片刷新'
    },
    setSliderX(x) {
      const max = sliderMaxFor(this.data.mode, this.data.words)
      const sliderX = Math.min(max, Math.max(0, Math.round(x)))
      this.applyModeLayout(sliderX)
    },
    resetInteraction(emitRefresh) {
      clearTimeout(this._autoTimer)
      clearTimeout(this._failTimer)
      const patch = {
        localValue: '',
        canConfirm: false,
        status: 'idle',
        checking: false,
        sliderX: 0,
        dragging: false,
        rotateDeg: 0,
        pieceLeftPercent: 0,
        trackPercent: 0,
        wordClicks: [],
        wordMarks: [],
        patternMark: null,
        markText: '✓'
      }
      this.setData({
        ...patch,
        statusHint: this.buildStatusHint(patch)
      })
      this.applyModeLayout(0)
      this.updateHints()
      if (emitRefresh) this.triggerEvent('refresh')
    },
    open() {
      this.setData({
        visible: true,
        wordNeed: (this.data.words && this.data.words.length) || 3
      })
      this.resetInteraction(false)
      this.updateHints()
      if (this.data.mode === 'pow' || this.data.mode === 'turnstile') {
        wx.showToast({
          title: '请改用点选/拼图/曲线/旋转验证码',
          icon: 'none'
        })
      }
      setTimeout(() => {
        this.triggerEvent('refresh')
      }, 16)
    },
    close() {
      clearTimeout(this._autoTimer)
      clearTimeout(this._failTimer)
      this.setData({
        visible: false,
        localValue: '',
        canConfirm: false,
        status: 'idle',
        checking: false,
        wordMarks: [],
        patternMark: null,
        dragging: false
      })
      this.updateHints()
    },
    onRefresh() {
      if (this.data.checking) return
      this.resetInteraction(true)
    },
    commitSuccess(captcha) {
      const committed = String(captcha)
      this.setData({
        committed,
        verified: true,
        visible: false,
        localValue: '',
        status: 'idle',
        checking: false,
        canConfirm: false
      })
      this.updateHints()
      this.triggerEvent('confirm', { value: committed })
      this.triggerEvent('change', { value: committed })
    },
    async confirm() {
      if (this.data.checking) return
      const mode = this.data.mode
      if (mode === 'pow' || mode === 'turnstile') {
        wx.showToast({ title: '请更换验证码类型', icon: 'none' })
        return
      }

      // 交互型已预校验通过
      if (this.isInteractiveMode(mode)) {
        if (this.data.status !== 'ok' || !this.data.localValue) return
        this.commitSuccess(this.data.localValue)
        return
      }

      // 输入型：提交前预校验，错误直接提示（对齐 uniapp）
      const captcha = String(this.data.localValue || '').trim()
      if (!captcha) {
        wx.showToast({ title: '请先填写验证码', icon: 'none' })
        return
      }
      const key = this.data.captchaKey
      if (!key) {
        wx.showToast({ title: '验证码已失效，请刷新', icon: 'none' })
        this.onRefresh()
        return
      }
      this.setData({ checking: true })
      this.updateHints()
      try {
        const { data } = await useCaptchaCheckApi({ key, captcha })
        if (data === true) {
          this.setData({ status: 'ok', checking: false, localValue: captcha })
          this.commitSuccess(captcha)
        } else {
          this.setData({ checking: false, localValue: '', canConfirm: false, status: 'fail' })
          this.updateHints()
          wx.showToast({ title: '验证码错误', icon: 'none' })
          setTimeout(() => this.onRefresh(), 400)
        }
      } catch (e) {
        this.setData({ checking: false, localValue: '', canConfirm: false, status: 'fail' })
        this.updateHints()
        wx.showToast({ title: e?.msg || '验证失败，请重试', icon: 'none' })
        setTimeout(() => this.onRefresh(), 400)
      }
    },
    reset() {
      clearTimeout(this._autoTimer)
      clearTimeout(this._failTimer)
      this.setData({
        committed: '',
        verified: false,
        localValue: '',
        canConfirm: false,
        visible: false,
        status: 'idle',
        checking: false,
        wordMarks: [],
        patternMark: null,
        dragging: false
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
      const localValue = e.detail.value || ''
      this.setData({
        localValue,
        status: 'idle'
      })
      this.updateHints()
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
      this.setSliderX(ratio * sliderMaxFor(this.data.mode, this.data.words))
    },
    onTrackStart(e) {
      if (this.data.checking || this.data.status === 'ok') return
      this._dragging = true
      this.setData({
        dragging: true,
        status: 'idle',
        localValue: '',
        canConfirm: false
      })
      const t = e.touches && e.touches[0]
      this.measureTrack(() => {
        if (t) this.applyClientX(t.clientX)
      })
      this.updateHints()
    },
    onTrackMove(e) {
      if (!this._dragging) return
      const t = e.touches && e.touches[0]
      if (t) this.applyClientX(t.clientX)
    },
    onTrackEnd() {
      if (!this._dragging) return
      this._dragging = false
      this.setData({ dragging: false })
      if (this.data.sliderX < 8) {
        this.setSliderX(0)
        this.setData({ localValue: '', canConfirm: false, status: 'idle' })
        this.updateHints()
        return
      }
      const mode = this.data.mode
      if (mode === 'rotate' || mode === 'angle') {
        this.precheck(String(Math.round((this.data.sliderX / sliderMaxFor(mode, this.data.words)) * 360)))
        return
      }
      this.precheck(String(this.data.sliderX))
    },
    resolveTap(e, selector, cb) {
      wx.createSelectorQuery()
        .in(this)
        .select(selector)
        .boundingClientRect((rect) => {
          if (!rect || !rect.width) {
            cb(null)
            return
          }
          const touch = (e.touches && e.touches[0]) || (e.changedTouches && e.changedTouches[0])
          const clientX = touch ? touch.clientX : (e.detail && e.detail.x) || 0
          const clientY = touch ? touch.clientY : (e.detail && e.detail.y) || 0
          const relX = clientX - rect.left
          const relY = clientY - rect.top
          if (relX < 0 || relY < 0 || relX > rect.width || relY > rect.height) {
            cb(null)
            return
          }
          cb({
            left: (relX / rect.width) * 100,
            top: (relY / Math.max(1, rect.height)) * 100,
            x: Math.round((relX / rect.width) * PUZZLE_W),
            y: Math.round((relY / Math.max(1, rect.height)) * PUZZLE_H)
          })
        })
        .exec()
    },
    onPatternTap(e) {
      if (this.data.checking || this.data.status === 'ok' || this.data.status === 'fail') return
      this.resolveTap(e, '.pattern-box-inner.clickable', (point) => {
        if (!point) {
          wx.showToast({ title: '请点选图中图案', icon: 'none' })
          return
        }
        this.setData({
          patternMark: { left: point.left, top: point.top },
          markText: '✓',
          status: 'idle',
          localValue: '',
          canConfirm: false
        })
        this.updateHints()
        this.precheck(`${point.x},${point.y}`)
      })
    },
    onWordTap(e) {
      if (this.data.checking || this.data.status === 'ok' || this.data.status === 'fail') return
      const need = this.data.wordNeed || 3
      this.resolveTap(e, '.word-stage', (point) => {
        if (!point) {
          wx.showToast({ title: '请依次点选文字', icon: 'none' })
          return
        }
        let clicks = this.data.wordClicks.slice()
        let marks = this.data.wordMarks.slice()
        if (clicks.length >= need) {
          clicks = []
          marks = []
        }
        clicks.push(`${point.x},${point.y}`)
        marks.push({ left: point.left, top: point.top })
        this.setData({
          wordClicks: clicks,
          wordMarks: marks,
          markText: '✓',
          localValue: '',
          canConfirm: false,
          status: 'idle'
        })
        this.updateHints()
        if (clicks.length < need) return
        this.precheck(clicks.join('|'))
      })
    },
    async precheck(captcha) {
      const key = this.data.captchaKey
      if (!key) {
        wx.showToast({ title: '验证码已失效，请刷新', icon: 'none' })
        this.onRefresh()
        return
      }
      this.setData({
        checking: true,
        statusHint: this.buildStatusHint({ checking: true })
      })
      this.updateHints()
      try {
        const { data } = await useCaptchaCheckApi({ key, captcha })
        if (data === true) {
          const patch = {
            status: 'ok',
            checking: false,
            localValue: captcha,
            canConfirm: true,
            markText: '✓'
          }
          this.setData({
            ...patch,
            statusHint: this.buildStatusHint(patch)
          })
          this.updateHints()
          clearTimeout(this._autoTimer)
          this._autoTimer = setTimeout(() => {
            if (this.data.visible && this.data.status === 'ok' && this.data.localValue) {
              this.commitSuccess(this.data.localValue)
            }
          }, 320)
        } else {
          this.onPrecheckFail()
        }
      } catch (e) {
        this.onPrecheckFail()
      }
    },
    failMessage() {
      const mode = this.data.mode
      if (mode === 'curve' || mode === 'slider') return '未对齐'
      if (mode === 'rotate' || mode === 'angle') return '角度错误'
      if (mode === 'word') return '点选错误'
      if (mode === 'click') return '选择错误'
      return '验证码错误'
    },
    onPrecheckFail() {
      const patch = {
        status: 'fail',
        checking: false,
        localValue: '',
        canConfirm: false,
        markText: '!'
      }
      this.setData({
        ...patch,
        statusHint: this.buildStatusHint(patch)
      })
      this.updateHints()
      wx.showToast({
        title: this.failMessage(),
        icon: 'none',
        duration: 1500
      })
      clearTimeout(this._failTimer)
      this._failTimer = setTimeout(() => {
        this.resetInteraction(true)
        this.triggerEvent('change', { value: '' })
      }, 1200)
    }
  }
})
