const brand = require('@/config/brand.js')

const FEATURE_ICONS = [
  '/images/icons/lock.svg',
  '/images/icons/settings.svg',
  '/images/icons/org.svg',
  '/images/icons/about.svg'
]

Page({
  data: {
    brand,
    pills: String(brand.homeLine || '')
      .split(/[·•]/)
      .map((s) => s.trim())
      .filter(Boolean),
    features: (brand.features || []).map((item, index) => ({
      ...item,
      icon: FEATURE_ICONS[index] || FEATURE_ICONS[0]
    }))
  }
})
