const { validateForm } = require('@/utils/validator.js')
const cache = require('@/utils/cache.js')
const { updatePasswordApi } = require('@/api/user.js')

Page({
  data: {},

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
    }
  },

  onLoad(options) {},

  onPassword(e) {
    const dataForm = e.detail.value
    const rules = {
      password: [{ required: true, message: '原密码不能为空' }],
      newPassword: [
        { required: true, message: '新密码不能为空' },
        { pattern: /^.{4,20}$/, message: '新密码必须是4-20位字符' }
      ],
      confirmPassword: [{ required: true, message: '确认密码不能为空' }]
    }
    // 表单验证失败
    if (!validateForm(dataForm, rules)) {
      return
    }
    // 新密码、确认密码，是否相等
    if (dataForm.newPassword != dataForm.confirmPassword) {
      wx.showToast({
        title: '新密码与确认密码不一致',
        icon: 'none',
        duration: 2000
      })
      return
    }

    // 修改密码
    updatePasswordApi(dataForm).then(() => {
      wx.navigateBack()
    })
  }
})
