const cache = require('@/utils/cache.js')
const { t } = require('@/locale/index.js')
const { showIceToast } = require('@/utils/iceToast.js')
const { useUserInfoApi, useUserInfoSubmitApi } = require('@/api/user.js')

const FIELD_META = {
  realName: {
    key: 'realName',
    inputType: 'text',
    maxlength: 20,
    icon: '/images/icons/name.svg',
    theme: 'dark',
    titleKey: 'profile.editName',
    labelKey: 'profile.name',
    descKey: 'profile.nameDesc',
    tipKey: 'profile.nameLabelTip',
    phKey: 'profile.namePh',
    emptyKey: 'profile.emptyName'
  },
  mobile: {
    key: 'mobile',
    inputType: 'number',
    maxlength: 11,
    icon: '/images/icons/phone.svg',
    theme: 'cyan',
    titleKey: 'profile.editMobile',
    labelKey: 'profile.mobile',
    descKey: 'profile.mobileDesc',
    tipKey: 'profile.mobileLabelTip',
    phKey: 'profile.mobilePh',
    emptyKey: 'profile.emptyMobile'
  },
  email: {
    key: 'email',
    inputType: 'text',
    maxlength: 50,
    icon: '/images/icons/email.svg',
    theme: 'sky',
    titleKey: 'profile.editEmail',
    labelKey: 'profile.email',
    descKey: 'profile.emailDesc',
    tipKey: 'profile.emailLabelTip',
    phKey: 'profile.emailPh',
    emptyKey: 'profile.emptyEmail'
  }
}

Page({
  data: {
    fieldKey: 'realName',
    formValue: '',
    originalValue: '',
    saving: false,
    user: {
      realName: '',
      mobile: '',
      email: '',
      gender: 2
    },
    activeField: {},
    copy: {}
  },

  onLoad(options) {
    const nextKey = options?.key
    const fieldKey = FIELD_META[nextKey] ? nextKey : 'realName'
    const userInfo = cache.getUserInfo() || {}
    const user = {
      realName: userInfo.realName || '',
      mobile: userInfo.mobile || '',
      email: userInfo.email || '',
      gender: userInfo.gender ?? 2
    }
    const formValue = user[fieldKey] || ''
    this.setData({
      fieldKey,
      user,
      formValue,
      originalValue: formValue
    })
    this.refreshCopy()
  },

  onShow() {
    if (!cache.getToken()) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.refreshCopy()
  },

  refreshCopy() {
    const meta = FIELD_META[this.data.fieldKey] || FIELD_META.realName
    this.setData({
      activeField: {
        ...meta,
        title: t(meta.titleKey),
        label: t(meta.labelKey),
        desc: t(meta.descKey),
        tip: t(meta.tipKey),
        placeholder: t(meta.phKey),
        emptyText: t(meta.emptyKey)
      },
      copy: {
        original: t('profile.original'),
        next: t('profile.next'),
        saveEdit: t('profile.saveEdit')
      }
    })
  },

  onInput(e) {
    this.setData({ formValue: (e.detail.value || '').trimStart() })
  },

  validateValue() {
    const value = (this.data.formValue || '').trim()
    const fieldKey = this.data.fieldKey
    if (fieldKey === 'realName' && !value) {
      showIceToast({ title: t('profile.nameRequired'), icon: 'none' })
      return false
    }
    if (fieldKey === 'mobile') {
      if (!value) {
        showIceToast({ title: t('profile.mobileRequired'), icon: 'none' })
        return false
      }
      if (!/^1[3-9]\d{9}$/.test(value)) {
        showIceToast({ title: t('profile.mobileInvalid'), icon: 'none' })
        return false
      }
    }
    if (fieldKey === 'email') {
      if (!value) {
        showIceToast({ title: t('profile.emailRequired'), icon: 'none' })
        return false
      }
      if (!/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/.test(value)) {
        showIceToast({ title: t('profile.emailInvalid'), icon: 'none' })
        return false
      }
    }
    return true
  },

  async onSubmit() {
    if (this.data.saving) return
    if (!this.validateValue()) return
    const value = (this.data.formValue || '').trim()
    if (value === (this.data.originalValue || '').trim()) {
      showIceToast({ title: t('profile.noChange'), icon: 'none' })
      return
    }
    this.setData({ saving: true, formValue: value })
    try {
      const payload = { ...this.data.user, [this.data.fieldKey]: value }
      await useUserInfoSubmitApi(payload)
      const userResponse = await useUserInfoApi()
      const latestUser = userResponse?.data || payload
      const nextValue = latestUser[this.data.fieldKey] || value
      const user = { ...this.data.user, ...latestUser }
      this.setData({
        user,
        formValue: nextValue,
        originalValue: nextValue
      })
      cache.setUserInfo({ ...(cache.getUserInfo() || {}), ...latestUser })
      showIceToast({ title: t('profile.saveOk'), icon: 'success' })
      setTimeout(() => wx.navigateBack(), 600)
    } catch (error) {
      showIceToast({ title: (error && error.msg) || t('common.fail'), icon: 'none' })
    } finally {
      this.setData({ saving: false })
    }
  }
})
