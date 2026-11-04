const cache = require('@/utils/cache.js')
const request = require('@/utils/request.js')
const { showIceToast } = require('@/utils/iceToast.js')
const { t } = require('@/locale/index.js')
const { useUserInfoApi, useUserInfoSubmitApi, useUserAvatarApi } = require('@/api/user.js')

const DEFAULT_AVATAR = '/images/logo.png'

Page({
  data: {
    uploadingAvatar: false,
    savingGender: false,
    user: {
      id: '',
      avatar: '',
      realName: '',
      mobile: '',
      email: '',
      gender: 2
    },
    displayAvatar: DEFAULT_AVATAR,
    genderLabel: '',
    genderList: [],
    copy: {}
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.refreshCopy()
    this.loadUser()
  },

  refreshCopy() {
    const genderList = [
      {
        label: t('profile.male'),
        value: 0,
        tone: 'male',
        desc: t('profile.maleDesc'),
        art: '/images/profile/gender-male.jpg'
      },
      {
        label: t('profile.unknown'),
        value: 2,
        tone: 'unknown',
        desc: t('profile.unknownDesc'),
        art: '/images/profile/gender-unknown.jpg'
      },
      {
        label: t('profile.female'),
        value: 1,
        tone: 'female',
        desc: t('profile.femaleDesc'),
        art: '/images/profile/gender-female.jpg'
      }
    ]
    const gender = Number(this.data.user.gender)
    const current = genderList.find((item) => item.value === gender)
    this.setData({
      genderList,
      genderLabel: current ? current.label : t('profile.unknown'),
      copy: {
        title: t('profile.title'),
        sub: t('profile.sub'),
        noName: t('profile.noName'),
        fillMobile: t('profile.fillMobile'),
        accountInfo: t('profile.accountInfo'),
        basic: t('profile.basic'),
        tapEdit: t('profile.tapEdit'),
        name: t('profile.name'),
        nameTip: t('profile.nameTip'),
        mobile: t('profile.mobile'),
        mobileTip: t('profile.mobileTip'),
        email: t('profile.email'),
        emailTip: t('profile.emailTip'),
        pleaseFill: t('profile.pleaseFill'),
        gender: t('profile.gender'),
        genderSave: t('profile.genderSave')
      }
    })
  },

  async loadUser() {
    try {
      const response = await useUserInfoApi()
      const userInfo = response?.data || {}
      const user = {
        id: userInfo.id || '',
        avatar: userInfo.avatar || '',
        realName: userInfo.realName || '',
        mobile: userInfo.mobile || '',
        email: userInfo.email || '',
        gender:
          userInfo.gender === undefined || userInfo.gender === null || userInfo.gender === ''
            ? 2
            : Number(userInfo.gender)
      }
      cache.setUserInfo(user)
      const current = this.data.genderList.find((item) => item.value === Number(user.gender))
      this.setData({
        user,
        displayAvatar: user.avatar || DEFAULT_AVATAR,
        genderLabel: current ? current.label : t('profile.unknown')
      })
    } catch (error) {
      showIceToast({ title: t('profile.loadFail'), icon: 'none' })
    }
  },

  navigateToInput(e) {
    const key = e.currentTarget.dataset.key
    if (!key) return
    wx.navigateTo({ url: `input/input?key=${key}` })
  },

  async uploadAvatar() {
    if (this.data.uploadingAvatar) return
    this.setData({ uploadingAvatar: true })
    let loadingShown = false
    try {
      const tempFilePath = await new Promise((resolve, reject) => {
        wx.chooseMedia({
          mediaType: ['image'],
          count: 1,
          success: (res) => resolve((res.tempFiles && res.tempFiles[0] && res.tempFiles[0].tempFilePath) || ''),
          fail: (err) => reject(err)
        })
      })
      if (!tempFilePath) throw new Error('未获取到图片')
      wx.showLoading({ title: '上传中...' })
      loadingShown = true
      const { data } = await request.upload('/sys/file/upload', tempFilePath)
      await useUserAvatarApi({ avatar: data.url })
      const user = { ...this.data.user, avatar: data.url }
      this.setData({
        user,
        displayAvatar: data.url
      })
      cache.setUserInfo(user)
      showIceToast({ title: t('profile.avatarOk'), icon: 'success' })
    } catch (error) {
      if (error && error.errMsg && String(error.errMsg).includes('cancel')) return
      showIceToast({ title: t('profile.avatarFail'), icon: 'none' })
    } finally {
      if (loadingShown) wx.hideLoading()
      this.setData({ uploadingAvatar: false })
    }
  },

  async selectGender(e) {
    const index = e.currentTarget.dataset.index
    const item = this.data.genderList[index]
    if (!item || this.data.savingGender) return
    const nextGender = Number(item.value)
    if (Number(this.data.user.gender) === nextGender) return

    this.setData({ savingGender: true })
    const prevGender = this.data.user.gender
    const user = { ...this.data.user, gender: nextGender }
    this.setData({
      user,
      genderLabel: item.label
    })

    try {
      await useUserInfoSubmitApi(user)
      cache.setUserInfo(user)
      showIceToast({
        title: t('profile.genderSwitched', { name: item.label }),
        sub: t('profile.genderSwitchedSub'),
        art: item.art,
        tone: item.tone || 'ok'
      })
    } catch (error) {
      this.setData({
        user: { ...this.data.user, gender: prevGender },
        genderLabel:
          (this.data.genderList.find((g) => g.value === Number(prevGender)) || {}).label ||
          t('profile.unknown')
      })
      showIceToast({
        title: t('profile.genderFail'),
        sub: t('profile.genderFailSub'),
        tone: 'fail'
      })
    } finally {
      this.setData({ savingGender: false })
    }
  }
})
