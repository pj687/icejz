const cache = require('@/utils/cache.js')
const { validateForm } = require('@/utils/validator.js')
const { useUserInfoSubmitApi } = require('@/api/user.js')

Page({
  data: {},
  onLoad(options) {
    const key = options.key
    const userInfo = cache.getUserInfo()

    const user = {}
    user[key] = userInfo[key]
    this.setData({
      user
    })
  },
  onSubmit(e) {
    const dataForm = e.detail.value

    const rules = {
      realName: [{ required: true, message: '姓名不能为空' }],
      mobile: [
        { required: true, message: '手机号不能为空' },
        { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' }
      ],
      email: [
        { required: true, message: '邮箱不能为空' },
        { pattern: /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/, message: '邮箱格式不正确' }
      ]
    }
    // 表单验证失败
    if (!validateForm(dataForm, rules)) {
      return
    }

    const { realName, email, mobile, gender } = cache.getUserInfo()
    const data = { realName, email, mobile, gender, ...dataForm }
    useUserInfoSubmitApi(data).then(() => {
      wx.navigateBack({ backRefresh: true })
    })
  }
})
