const { validateForm } = require('@/utils/validator.js')
const { sm2Encrypt } = require('@/utils/sm2.js')
const cache = require('@/utils/cache.js')
const { useCaptchaEnabledApi, useCaptchaApi, useLoginApi } = require('@/api/auth.js')
const { useUserInfoApi } = require('@/api/user.js')

Page({
  data: {
    captchaVisible: false,
    captchaBase64: '',
    captchakey: ''
  },
  async onLoad() {
    // 判断是否开启验证码
    const res = await useCaptchaEnabledApi()
    this.setData({ captchaVisible: res.data })
    if (res.data) {
      this.onCaptcha()
    }
  },
  onLogin(e) {
    const loginForm = e.detail.value
    const rules = {
      username: [{ required: true, message: '账号不能为空' }],
      password: [{ required: true, message: '密码不能为空' }],
      captcha: [{ required: true, message: '验证码不能为空' }]
    }
    // 表单验证失败
    if (!validateForm(loginForm, rules)) {
      return
    }

    // 如果有验证码，则把验证码key带上
    if (this.data.captchaVisible) {
      loginForm.key = this.data.captchakey
    }

    // 密码sm2加密
    loginForm.password = sm2Encrypt(loginForm.password)

    // 登录
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
        }
      })
  },

  async onCaptcha() {
    const { data } = await useCaptchaApi()
    this.setData({
      captchakey: data.key,
      captchaBase64: data.image
    })
  },

  /**
   * 登录成功后，初始化一些数据
   */
  async initData() {
    const { data } = await useUserInfoApi()
    cache.setUserInfo(data)
  },
  onShow() {
    // token存在，则跳转到首页
    if (cache.getToken()) {
      wx.reLaunch({
        url: '/pages/index/index'
      })
    }
  }
})
