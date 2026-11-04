const { validateForm } = require('@/utils/validator.js')
const { sm2Encrypt } = require('@/utils/sm2.js')
const cache = require('@/utils/cache.js')
const brand = require('@/config/brand.js')
const { getLocale, setAppLocale, t } = require('@/locale/index.js')
const { showIceToast } = require('@/utils/iceToast.js')
const {
  useCaptchaEnabledApi,
  useCaptchaApi,
  useLoginApi,
  useSendCodeApi,
  useMobileLoginApi,
  useCompleteProfileApi
} = require('@/api/auth.js')
const { useUserInfoApi } = require('@/api/user.js')
const { goAfterAuth } = require('@/utils/guide.js')

const TYPE_MODE = {
  pattern: 'click',
  block_puzzle: 'slider',
  click_word: 'word',
  curve: 'curve',
  rotate: 'rotate',
  angle: 'angle',
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
    statusBarPx: 20,
    locale: 'zh-CN',
    localeShort: '中',
    nextLocaleShort: 'EN',
    copy: {},
    agreed: false,
    isLogging: false,
    isCompleting: false,
    showCompleteProfile: false,
    loginMode: 'account',
    canSubmit: false,
    captchaEnabled: true,
    captchaBase64: '',
    captchaKey: '',
    captchaMode: 'input',
    captchaTip: '',
    captchaValue: '',
    jigsawImage: '',
    jigsawY: 0,
    captchaWords: [],
    phoneHint: '请输入11位手机号',
    inputErrors: { mobile: '', captcha: '', code: '' },
    completeErrors: { realName: '', roleId: '', gender: '' },
    accountForm: {
      username: 'admin',
      password: '123456'
    },
    mobileForm: {
      mobile: '',
      code: ''
    },
    completeForm: {
      userId: '',
      mobile: '',
      realName: '',
      roleId: null,
      gender: 2,
      orgId: null
    },
    roleOptions: [
      { key: 'dev', label: '研发', value: 2, tip: '开发工具与物联网能力' },
      { key: 'ops', label: '运维', value: 3, tip: '日志、监控与定时任务' },
      { key: 'pm', label: '产品', value: 4, tip: '日常协作与业务查阅' }
    ],
    genderOptions: [
      { key: 'male', label: '男', value: 0 },
      { key: 'female', label: '女', value: 1 },
      { key: 'unknown', label: '未知', value: 2 }
    ],
    sms: {
      disabled: false,
      total: 60,
      count: 0
    }
  },

  smsTimer: null,

  onLoad() {
    try {
      this.setData({ statusBarPx: wx.getSystemInfoSync().statusBarHeight || 20 })
    } catch (e) {
      this.setData({ statusBarPx: 20 })
    }
    this.refreshLocale()
    this.initCaptcha()
  },

  onShow() {
    if (cache.getToken()) {
      goAfterAuth({ replace: true })
      return
    }
    this.refreshLocale()
  },

  onUnload() {
    this.clearSmsTimer()
  },

  refreshLocale() {
    const locale = getLocale()
    this.setData({
      locale,
      localeShort: locale === 'en-US' ? 'EN' : '中',
      nextLocaleShort: locale === 'en-US' ? '中' : 'EN',
      copy: {
        slogan: t('brand.slogan'),
        tagline: t('brand.tagline'),
        welcomeKicker: t('login.welcomeKicker'),
        loginHint: t('brand.loginHint'),
        accountLogin: t('login.accountLogin'),
        mobileLogin: t('login.mobileLogin'),
        account: t('login.account'),
        accountPh: t('login.accountPh'),
        password: t('login.password'),
        passwordPh: t('login.passwordPh'),
        security: t('login.security'),
        login: t('login.login'),
        logging: t('login.logging'),
        mobile: t('login.mobile'),
        mobilePh: t('login.mobilePh'),
        sms: t('login.sms'),
        smsPh: t('login.smsPh'),
        sendCode: t('login.sendCode'),
        captchaBeforeSms: t('login.captchaBeforeSms'),
        secureEncrypt: t('login.secureEncrypt'),
        secureAuth: t('login.secureAuth'),
        secureAudit: t('login.secureAudit'),
        footnote: t('login.footnote'),
        footer: t('brand.footer')
      }
    })
    wx.setNavigationBarTitle({ title: brand.name || 'ICEJZ' })
  },

  toggleLocale() {
    const next = getLocale() === 'en-US' ? 'zh-CN' : 'en-US'
    setAppLocale(next)
    this.refreshLocale()
    showIceToast({ title: t('lang.switched'), icon: 'success' })
  },

  switchMode(e) {
    const mode = e.currentTarget.dataset.mode
    if (!mode || mode === this.data.loginMode) return
    this.setData({
      loginMode: mode,
      inputErrors: { mobile: '', captcha: '', code: '' }
    })
    this.refreshCanSubmit()
    this.onCaptcha()
  },

  onFieldInput(e) {
    const form = e.currentTarget.dataset.form
    const key = e.currentTarget.dataset.key
    if (!form || !key) return
    this.setData({ [`${form}.${key}`]: e.detail.value || '' })
    if (form === 'mobileForm' && key === 'code') {
      this.setData({ 'inputErrors.code': '' })
      this.refreshCanSubmit()
    }
    if (form === 'completeForm' && key === 'realName') {
      this.setData({ 'completeErrors.realName': '' })
    }
  },

  onPhoneInput(e) {
    const rawValue = String(e.detail.value || '')
      .replace(/\D/g, '')
      .slice(0, 11)
    let phoneHint = '请输入11位手机号'
    if (!rawValue) phoneHint = '请输入11位手机号'
    else if (rawValue.length < 11) phoneHint = `还需输入${11 - rawValue.length}位数字`
    else if (!/^1[3-9]\d{9}$/.test(rawValue)) phoneHint = '手机号格式不正确，请检查后重试'
    else phoneHint = '手机号格式正确'
    this.setData({
      'mobileForm.mobile': rawValue,
      phoneHint,
      'inputErrors.mobile': ''
    })
    this.refreshCanSubmit()
  },

  refreshCanSubmit() {
    const { isLogging, showCompleteProfile, loginMode, mobileForm } = this.data
    const canSubmit =
      !isLogging &&
      !showCompleteProfile &&
      loginMode === 'mobile' &&
      !!mobileForm.mobile &&
      !!mobileForm.code
    this.setData({ canSubmit })
  },

  async initCaptcha() {
    try {
      const res = await useCaptchaEnabledApi()
      this.setData({ captchaEnabled: !!res.data })
      if (res.data) this.onCaptcha()
    } catch (e) {
      this.setData({ captchaEnabled: true })
      this.onCaptcha()
    }
  },

  getCaptchaPopup() {
    const id = this.data.loginMode === 'mobile' ? '#captchaPopupMobile' : '#captchaPopup'
    return this.selectComponent(id) || this.selectComponent('#captchaPopup')
  },

  getAgreement() {
    return this.selectComponent('#agreement')
  },

  onAgreementChange(e) {
    this.setData({ agreed: !!(e.detail && e.detail.value) })
  },

  onCaptchaChange(e) {
    this.setData({
      captchaValue: e.detail?.value || '',
      'inputErrors.captcha': ''
    })
  },

  onCaptchaConfirm(e) {
    this.setData({
      captchaValue: e.detail?.value || '',
      'inputErrors.captcha': ''
    })
  },

  ensureCaptcha() {
    if (!this.data.captchaEnabled) return true
    if (this.data.captchaValue !== '' && this.data.captchaValue != null) return true
    this.getCaptchaPopup()?.open?.()
    showIceToast({ title: t('login.captchaRequired') || '请先完成安全验证', icon: 'none' })
    return false
  },

  ensureAgreement() {
    return this.getAgreement()?.ensureAgreed?.() ?? false
  },

  async onCaptcha() {
    if (this.data.showCompleteProfile) return
    try {
      const channel = this.data.loginMode === 'mobile' ? 'sms' : 'app'
      const { data } = await useCaptchaApi(channel)
      const mode = data.mode || TYPE_MODE[data.type] || 'input'
      this.setData({
        captchaKey: data.key || '',
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
      showIceToast({ title: e?.msg || '验证码加载失败', icon: 'none' })
    }
  },

  clearSmsTimer() {
    if (this.smsTimer) {
      clearInterval(this.smsTimer)
      this.smsTimer = null
    }
  },

  startSmsTimer() {
    this.clearSmsTimer()
    this.setData({
      'sms.count': this.data.sms.total,
      'sms.disabled': true
    })
    this.smsTimer = setInterval(() => {
      const count = this.data.sms.count
      if (count > 1) {
        this.setData({ 'sms.count': count - 1 })
      } else {
        this.clearSmsTimer()
        this.setData({ 'sms.disabled': false, 'sms.count': 0 })
      }
    }, 1000)
  },

  async sendCode() {
    if (this.data.sms.disabled || this.data.isLogging) return
    if (!/^1[3-9]\d{9}$/.test(this.data.mobileForm.mobile)) {
      this.setData({ 'inputErrors.mobile': '请输入正确的11位手机号' })
      return
    }
    if (!this.ensureCaptcha()) {
      this.setData({ 'inputErrors.captcha': '请先在弹窗中完成图形验证' })
      return
    }
    if (!this.data.captchaKey) {
      this.setData({ 'inputErrors.captcha': '图形验证码已失效，请点击刷新' })
      await this.onCaptcha()
      return
    }
    try {
      await useSendCodeApi({
        mobile: this.data.mobileForm.mobile,
        key: this.data.captchaKey,
        captcha: this.data.captchaValue
      })
      showIceToast({ title: '验证码已发送，请注意查收', icon: 'none' })
      this.startSmsTimer()
      await this.onCaptcha()
    } catch (error) {
      await this.onCaptcha()
      showIceToast({ title: error?.msg || '发送失败，请稍后重试', icon: 'none' })
    }
  },

  async onAccountLogin() {
    if (this.data.isLogging) return
    const loginForm = {
      username: this.data.accountForm.username,
      password: this.data.accountForm.password
    }
    const rules = {
      username: [{ required: true, message: t('login.accountRequired') || '账号不能为空' }],
      password: [{ required: true, message: t('login.passwordRequired') || '密码不能为空' }]
    }
    if (!validateForm(loginForm, rules)) return
    if (!this.ensureCaptcha()) return
    if (!this.ensureAgreement()) return

    const payload = {
      username: loginForm.username,
      password: sm2Encrypt(loginForm.password)
    }
    if (this.data.captchaEnabled) {
      payload.key = this.data.captchaKey
      payload.captcha = this.data.captchaValue
    }

    this.setData({ isLogging: true })
    try {
      const res = await useLoginApi(payload)
      await this.handleLoginSuccess(res)
    } catch (e) {
      if (this.data.captchaEnabled) {
        await this.onCaptcha()
        this.getCaptchaPopup()?.reset?.()
      }
    } finally {
      this.setData({ isLogging: false })
      this.refreshCanSubmit()
    }
  },

  async onMobileLogin() {
    if (this.data.isLogging || !this.data.canSubmit) return
    this.setData({ inputErrors: { mobile: '', captcha: '', code: '' } })

    if (!/^1[3-9]\d{9}$/.test(this.data.mobileForm.mobile)) {
      this.setData({ 'inputErrors.mobile': '请输入正确的11位手机号' })
      return
    }
    if (!this.data.mobileForm.code) {
      this.setData({ 'inputErrors.code': '请输入短信验证码' })
      return
    }
    if (!this.ensureAgreement()) return

    this.setData({ isLogging: true })
    this.refreshCanSubmit()
    try {
      const response = await useMobileLoginApi({
        mobile: this.data.mobileForm.mobile,
        code: this.data.mobileForm.code
      })
      await this.handleMobileLoginResult(response)
    } catch (error) {
      showIceToast({ title: error?.msg || '登录失败，请检查网络连接', icon: 'none' })
    } finally {
      this.setData({ isLogging: false })
      this.refreshCanSubmit()
    }
  },

  async handleMobileLoginResult(response) {
    if (!(response && response.code === 0)) {
      throw response || new Error('登录失败')
    }
    const result = response.data || {}
    if (result.needCompleteProfile) {
      this.setData({
        showCompleteProfile: true,
        'completeForm.userId': result.userId,
        'completeForm.mobile': result.mobile || this.data.mobileForm.mobile,
        'completeForm.realName': '',
        'completeForm.roleId':
          Array.isArray(result.roleIdList) && result.roleIdList.length ? result.roleIdList[0] : null,
        'completeForm.gender': 2,
        'completeForm.orgId': null,
        completeErrors: { realName: '', roleId: '', gender: '' }
      })
      showIceToast({
        title: result.firstLogin ? '首次登录，请完善信息' : '请完善信息后继续',
        icon: 'none'
      })
      return
    }
    await this.handleLoginSuccess({ code: 0, data: result })
  },

  selectRole(e) {
    const value = Number(e.currentTarget.dataset.value)
    this.setData({
      'completeForm.roleId': value,
      'completeErrors.roleId': ''
    })
  },

  selectGender(e) {
    const value = Number(e.currentTarget.dataset.value)
    this.setData({
      'completeForm.gender': value,
      'completeErrors.gender': ''
    })
  },

  backToLogin() {
    if (this.data.isCompleting) return
    this.setData({
      showCompleteProfile: false,
      completeErrors: { realName: '', roleId: '', gender: '' }
    })
    this.onCaptcha()
  },

  async submitCompleteProfile() {
    if (this.data.isCompleting) return
    const form = this.data.completeForm
    const completeErrors = { realName: '', roleId: '', gender: '' }
    let ok = true
    if (!form.realName) {
      completeErrors.realName = '请输入真实姓名'
      ok = false
    }
    if (!form.roleId) {
      completeErrors.roleId = '请选择身份角色'
      ok = false
    }
    this.setData({ completeErrors })
    if (!ok) return

    this.setData({ isCompleting: true })
    try {
      const response = await useCompleteProfileApi({
        userId: form.userId,
        roleId: form.roleId,
        realName: form.realName,
        gender: form.gender,
        mobile: form.mobile,
        orgId: form.orgId,
        password: sm2Encrypt(form.mobile)
      })
      await this.handleLoginSuccess(response)
    } catch (error) {
      showIceToast({ title: error?.msg || '提交失败，请稍后重试', icon: 'none' })
    } finally {
      this.setData({ isCompleting: false })
    }
  },

  async handleLoginSuccess(response) {
    if (!(response && response.code === 0)) {
      throw response || new Error('登录失败')
    }
    const tokenData = response.data || {}
    const accessToken =
      tokenData.access_token || tokenData.accessToken || tokenData.token || tokenData
    if (!accessToken || typeof accessToken !== 'string') {
      throw new Error('登录令牌为空')
    }
    cache.setToken(accessToken)
    try {
      const userResponse = await useUserInfoApi()
      if (userResponse && userResponse.code === 0) cache.setUserInfo(userResponse.data)
    } catch (e) {
      // ignore
    }
    this.setData({ showCompleteProfile: false })
    showIceToast({ title: '登录成功', icon: 'success' })
    setTimeout(() => goAfterAuth({ replace: true }), 800)
  }
})
