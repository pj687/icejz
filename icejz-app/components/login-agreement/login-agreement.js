const { AGREEMENTS, AGREEMENT_STORAGE_KEY, AGREEMENT_VERSION } = require('./agreements.js')

function loadOk() {
  try {
    return wx.getStorageSync(AGREEMENT_STORAGE_KEY) === '1'
  } catch (e) {
    return false
  }
}

function emptyFlags() {
  const map = {}
  AGREEMENTS.forEach((a) => {
    map[a.id] = false
  })
  return map
}

function allTrueFlags() {
  const map = {}
  AGREEMENTS.forEach((a) => {
    map[a.id] = true
  })
  return map
}

Component({
  properties: {
    value: { type: Boolean, value: false }
  },
  data: {
    version: AGREEMENT_VERSION,
    agreements: AGREEMENTS,
    agreed: false,
    visible: false,
    activeId: AGREEMENTS[0].id,
    confirmedMap: emptyFlags(),
    reachedEnd: false,
    current: AGREEMENTS[0],
    currentIndex: 0,
    confirmedCount: 0,
    canAgree: false,
    mainText: '请滑至文末',
    meterPercent: 0,
    docScrollTop: 0
  },
  lifetimes: {
    attached() {
      const ok = loadOk()
      const agreed = typeof this.properties.value === 'boolean' ? this.properties.value : ok
      const confirmedMap = ok ? allTrueFlags() : emptyFlags()
      this.setData({ agreed, confirmedMap })
      this.refreshDerived()
      this.triggerEvent('change', { value: agreed })
    }
  },
  observers: {
    value(v) {
      if (typeof v === 'boolean') {
        this.setData({ agreed: v })
      }
    }
  },
  methods: {
    noop() {},
    refreshDerived() {
      const { agreements, activeId, confirmedMap, reachedEnd } = this.data
      const currentIndex = Math.max(
        0,
        agreements.findIndex((a) => a.id === activeId)
      )
      const current = agreements[currentIndex] || agreements[0]
      const confirmedCount = agreements.filter((a) => confirmedMap[a.id]).length
      const alreadyConfirmed = !!confirmedMap[activeId]
      const canAgree = reachedEnd || alreadyConfirmed
      const next = this.nextUnread(currentIndex, confirmedMap)
      let mainText = '请滑至文末'
      if (canAgree) {
        if (!alreadyConfirmed) {
          mainText = next ? '阅读并同意，下一份' : '阅读并同意'
        } else if (next) {
          mainText = '下一份未读'
        } else {
          mainText = '已阅读并同意'
        }
      }
      this.setData({
        current,
        currentIndex,
        confirmedCount,
        canAgree,
        mainText,
        meterPercent: (confirmedCount / agreements.length) * 100
      })
    },
    persist(v) {
      try {
        if (v) wx.setStorageSync(AGREEMENT_STORAGE_KEY, '1')
        else wx.removeStorageSync(AGREEMENT_STORAGE_KEY)
      } catch (e) {
        /* ignore */
      }
    },
    toast(t) {
      wx.showToast({ title: t, icon: 'none' })
    },
    setAgreed(v) {
      this.setData({ agreed: v })
      this.persist(v)
      this.triggerEvent('change', { value: v })
    },
    nextUnread(currentIndex, confirmedMap) {
      const agreements = this.data.agreements
      const i = currentIndex == null ? this.data.currentIndex : currentIndex
      const map = confirmedMap || this.data.confirmedMap
      const ring = [...agreements.slice(i + 1), ...agreements.slice(0, i)]
      return ring.find((a) => !map[a.id]) || null
    },
    onBarTap() {
      if (this.data.agreed) {
        this.setAgreed(false)
        return
      }
      const allDone = this.data.agreements.every((a) => this.data.confirmedMap[a.id])
      if (allDone) {
        this.setAgreed(true)
        return
      }
      const first =
        this.data.agreements.find((a) => !this.data.confirmedMap[a.id]) || this.data.agreements[0]
      this.open(first.id)
    },
    openByEvent(e) {
      this.open(e.currentTarget.dataset.id)
    },
    openPrev() {
      const prev = this.data.agreements[this.data.currentIndex - 1]
      if (prev) this.open(prev.id)
    },
    open(id) {
      const activeId = id || this.data.agreements[0].id
      const reachedEnd = !!this.data.confirmedMap[activeId]
      this.setData({
        activeId,
        visible: true,
        reachedEnd,
        docScrollTop: 0
      })
      this.refreshDerived()
      setTimeout(() => this.checkReachEnd(), 40)
      setTimeout(() => this.checkReachEnd(), 200)
    },
    close() {
      this.setData({ visible: false, reachedEnd: false })
    },
    onDocScroll(e) {
      this.checkReachEnd(e.detail?.scrollTop || 0)
    },
    checkReachEnd(scrollTop) {
      wx.createSelectorQuery()
        .in(this)
        .select('.doc')
        .boundingClientRect()
        .select('.doc-pad')
        .boundingClientRect()
        .exec((res) => {
          const box = res && res[0]
          const pad = res && res[1]
          if (!box || !pad) return
          this.markReach(scrollTop || 0, box.height || 0, pad.height || 0)
        })
    },
    markReach(scrollTop, viewport, content) {
      if (!viewport) return
      if (content <= viewport + 12 || scrollTop + viewport >= content - 36) {
        if (!this.data.reachedEnd) {
          this.setData({ reachedEnd: true })
          this.refreshDerived()
        }
      }
    },
    onConfirm() {
      if (!this.data.canAgree) return
      const confirmedMap = { ...this.data.confirmedMap, [this.data.activeId]: true }
      this.setData({ confirmedMap })
      const next = this.nextUnread(this.data.currentIndex, confirmedMap)
      if (next) {
        this.open(next.id)
        return
      }
      this.setAgreed(true)
      this.close()
      this.toast('已同意全部协议')
      this.refreshDerived()
    },
    ensureAgreed() {
      if (this.data.agreed) return true
      this.toast('请先阅读并同意相关协议')
      const first =
        this.data.agreements.find((a) => !this.data.confirmedMap[a.id]) || this.data.agreements[0]
      this.open(first.id)
      return false
    }
  }
})
