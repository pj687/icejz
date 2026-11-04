import { createI18n } from 'vue-i18n'
import zhCN from './zh-CN.js'
import enUS from './en-US.js'

export const LOCALE_KEY = 'app_locale'
export const LOCALES = [
  { code: 'zh-CN', labelKey: 'lang.zh' },
  { code: 'en-US', labelKey: 'lang.en' }
]

export function getStoredLocale() {
  try {
    const saved = uni.getStorageSync(LOCALE_KEY)
    if (saved === 'zh-CN' || saved === 'en-US') return saved
  } catch (e) {
    // ignore
  }
  return 'zh-CN'
}

export function setStoredLocale(locale) {
  try {
    uni.setStorageSync(LOCALE_KEY, locale)
  } catch (e) {
    // ignore
  }
}

const i18n = createI18n({
  legacy: true,
  globalInjection: true,
  locale: getStoredLocale(),
  fallbackLocale: 'zh-CN',
  messages: {
    'zh-CN': zhCN,
    'en-US': enUS
  }
})

export function setAppLocale(locale) {
  if (locale !== 'zh-CN' && locale !== 'en-US') return
  i18n.global.locale = locale
  setStoredLocale(locale)
}

export function t(key, params) {
  return i18n.global.t(key, params)
}

export default i18n
