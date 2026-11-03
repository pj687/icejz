const { validateForm } = require('@/utils/validator.js')
const { sm2Encrypt } = require('@/utils/sm2.js')
const cache = require('@/utils/cache.js')
const brand = require('@/config/brand.js')
const { useCaptchaEnabledApi, useCaptchaApi, useLoginApi } = require('@/api/auth.js')
const { useUserInfoApi } = require('@/api/user.js')

const TYPE_MODE = {
  pattern: 'click',
  block_puzzle: 'slider',
  click_word: 'word',
  pow: 'pow',
  turnstile: 'turnstile',
  spec: 'input',
  number: 'input',
  chinese: 'input',
  arithmetic: 'input'
}

Page({
  data: {
    brand,
    agreed: false,
    captchaVisible: false,
    captchaBase64: '',
    captchakey: '',
    captchaMode: 'input',
    captchaTip: '',
    captchaValue: '',
    jigsawImage: '',
    jigsawY: 0,
    captchaWords: []
  },
  async onLoad() {
    const res = await useCaptchaEnabledApi()
    this.setData({ captchaVisible: !!res.data })
    if (res.data) {
      this.onCaptcha()
    }
  },
  getCaptchaPopup() {
    return this.selectComponent('#captchaPopup')
  },
  getAgreement() {
    return this.selectComponent('#agreement')
  },
  onAgreementChange(e) {
    this.setData({ agreed: !!(e.detail && e.detail.value) })
  },
  onCaptchaChange(e) {
    this.setData({ captchaValue: e.detail?.value || '' })
  },
  onCaptchaConfirm(e) {
    this.setData({ captchaValue: e.detail?.value || '' })
  },
  ensureCaptcha() {
    if (!this.data.captchaVisible) return true
    if (this.data.captchaValue !== '' && this.data.captchaValue != null) return true
    const popup = this.getCaptchaPopup()
    popup?.open?.()
    wx.showToast({ title: '请先完成安全验证', icon: 'none' })
    return false
  },
  ensureAgreement() {
    return this.getAgreement()?.ensureAgreed?.() ?? false
  },
  onLogin(e) {
    const loginForm = e.detail.value
    const rules = {
      username: [{ required: true, message: '账号不能为空' }],
      password: [{ required: true, message: '密码不能为空' }]
    }

    if (!validateForm(loginForm, rules)) {
      return
    }

    if (!this.ensureCaptcha()) {
      return
    }

    if (!this.ensureAgreement()) {
      return
    }

    if (this.data.captchaVisible) {
      loginForm.key = this.data.captchakey
      loginForm.captcha = this.data.captchaValue
    }

    loginForm.password = sm2Encrypt(loginForm.password)

    useLoginApi(loginForm)
      .then(async (res) => {
        cache.setToken(res.data.access_token)
        await this.initData()
        wx.reLaunch({
          url: '/pages/index/index'
        })
      })
      .catch(() => {
        if (this.data.captchaVisible) {
          this.onCaptcha()
          this.getCaptchaPopup()?.reset?.()
        }
      })
  },

  async onCaptcha() {
    try {
      const { data } = await useCaptchaApi('app')
      const mode = data.mode || TYPE_MODE[data.type] || 'input'
      this.setData({
        captchakey: data.key || '',
        captchaBase64: data.image || '',
        captchaMode: mode,
        captchaTip: data.tip || '',
        captchaValue: '',
        jigsawImage: data.jigsawImage || '',
        jigsawY: data.jigsawY || 0,
        captchaWords: data.words || []
      })
      const popup = this.getCaptchaPopup()
      if (popup && !popup.data.visible) {
        popup.reset?.()
      }
    } catch (e) {
      wx.showToast({ title: e?.msg || '验证码加载失败', icon: 'none' })
    }
  },

  async initData() {
    const { data } = await useUserInfoApi()
    cache.setUserInfo(data)
  },
  onShow() {
    if (cache.getToken()) {
      wx.reLaunch({
        url: '/pages/index/index'
      })
    }
  }
})
