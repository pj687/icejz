const { validateForm } = require('@/utils/validator.js')
const cache = require('@/utils/cache.js')
const { t } = require('@/locale/index.js')
const { showIceToast } = require('@/utils/iceToast.js')
const { updatePasswordApi } = require('@/api/user.js')

Page({
  data: {
    saving: false,
    passwordForm: {
      password: '',
      newPassword: '',
      confirmPassword: ''
    },
    copy: {}
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.refreshCopy()
  },

  refreshCopy() {
    this.setData({
      copy: {
        title: t('password.title'),
        sub: t('password.sub'),
        tipMix: t('password.tipMix'),
        tipDiff: t('password.tipDiff'),
        old: t('password.old'),
        newPwd: t('password.newPwd'),
        confirm: t('password.confirm'),
        oldPh: t('password.oldPh'),
        newPh: t('password.newPh'),
        confirmPh: t('password.confirmPh'),
        save: t('password.save')
      }
    })
  },

  onInput(e) {
    const key = e.currentTarget.dataset.key
    if (!key) return
    this.setData({
      [`passwordForm.${key}`]: e.detail.value || ''
    })
  },

  async onPassword() {
    if (this.data.saving) return
    const dataForm = this.data.passwordForm
    const rules = {
      password: [{ required: true, message: t('password.oldRequired') }],
      newPassword: [
        { required: true, message: t('password.newRequired') },
        { pattern: /^.{4,20}$/, message: t('password.newPattern') }
      ],
      confirmPassword: [{ required: true, message: t('password.confirmRequired') }]
    }
    if (!validateForm(dataForm, rules)) return
    if (dataForm.newPassword != dataForm.confirmPassword) {
      showIceToast({ title: '新密码与确认密码不一致', icon: 'none' })
      return
    }
    this.setData({ saving: true })
    try {
      await updatePasswordApi(dataForm)
      showIceToast({ title: '密码修改成功', icon: 'success' })
      setTimeout(() => wx.navigateBack(), 600)
    } catch (error) {
      // request layer may already toast
    } finally {
      this.setData({ saving: false })
    }
  }
})
