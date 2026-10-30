const cache = require('@/utils/cache.js')
const request = require('@/utils/request.js')
const { useUserInfoApi, useUserInfoSubmitApi, useUserAvatarApi } = require('@/api/user.js')

Page({
  data: {
    user: {
      id: '',
      avatar: '',
      realName: '',
      mobile: '',
      email: '',
      gender: ''
    },
    genderVisible: false,
    genderList: [
      { label: '男', value: 0 },
      { label: '女', value: 1 },
      { label: '未知', value: 2 }
    ],
    genderMap: ['男', '女', '未知']
  },

  async onShow() {
    // 获取用户信息
    const { data } = await useUserInfoApi()
    cache.setUserInfo(data)
    this.setData({ user: data })
  },

  async uploadAvatar() {
    // 获取选择的头像路径
    const tempFilePath = await new Promise((resolve, reject) => {
      wx.chooseMedia({
        mediaType: ['image'],
        count: 1,
        success: (res) => {
          resolve(res.tempFiles[0].tempFilePath)
        },
        fail: (err) => reject(err)
      })
    })

    // 上传头像
    const { data } = await request.upload('/sys/file/upload', tempFilePath)

    // 修改用户头像
    await useUserAvatarApi({ avatar: data.url })
    this.data.user.avatar = data.url
    this.setData({ user: this.data.user })
    cache.setUserInfo(this.data.user)
  },
  onGenderOpen() {
    this.setData({ genderVisible: true })
  },
  onGenderCancel() {
    this.setData({ genderVisible: false })
  },
  onGenderChange(e) {
    const { value } = e.detail
    this.data.user.gender = value[0]
    this.setData({
      genderVisible: false,
      user: this.data.user
    })

    useUserInfoSubmitApi(this.data.user).then(() => {
      cache.setUserInfo(this.data.user)
    })
  }
})
