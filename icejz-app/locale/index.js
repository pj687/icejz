const zhCN = require('./zh-CN.js')
const enUS = require('./en-US.js')

const LOCALE_KEY = 'app_locale'
const messages = {
  'zh-CN': zhCN,
  'en-US': enUS
}

function getStoredLocale() {
  try {
    const saved = wx.getStorageSync(LOCALE_KEY)
    if (saved === 'zh-CN' || saved === 'en-US') return saved
  } catch (e) {
    // ignore
  }
  return 'zh-CN'
}

function setStoredLocale(locale) {
  try {
    wx.setStorageSync(LOCALE_KEY, locale)
  } catch (e) {
    // ignore
  }
}

function getLocale() {
  return getStoredLocale()
}

function setAppLocale(locale) {
  if (locale !== 'zh-CN' && locale !== 'en-US') return
  setStoredLocale(locale)
}

function lookup(dict, key) {
  if (!dict || !key) return ''
  const parts = String(key).split('.')
  let cur = dict
  for (let i = 0; i < parts.length; i++) {
    if (cur == null || typeof cur !== 'object') return ''
    cur = cur[parts[i]]
  }
  return typeof cur === 'string' ? cur : cur == null ? '' : String(cur)
}

function interpolate(text, params) {
  if (!params || typeof text !== 'string') return text
  return text.replace(/\{(\w+)\}/g, (_, k) => {
    return params[k] == null ? `{${k}}` : String(params[k])
  })
}

function t(key, params) {
  const locale = getLocale()
  let text = lookup(messages[locale], key)
  if (!text) text = lookup(messages['zh-CN'], key)
  if (!text) return key
  return interpolate(text, params)
}

module.exports = {
  LOCALE_KEY,
  getStoredLocale,
  setStoredLocale,
  getLocale,
  setAppLocale,
  t
}
