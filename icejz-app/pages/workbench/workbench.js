const imageCdn = 'https://tdesign.gtimg.com/mobile/demos'
const swiperList = [`${imageCdn}/swiper1.png`, `${imageCdn}/swiper2.png`]

Page({
  data: {
    current: 0,
    autoplay: false,
    duration: 500,
    interval: 2000,
    swiperList,

    img1: 'https://tdesign.gtimg.com/mobile/demos/example1.png',
    img2: 'https://tdesign.gtimg.com/mobile/demos/example2.png',
    img3: 'https://tdesign.gtimg.com/mobile/demos/example3.png'
  },
  onClick() {
    wx.showToast({
      title: '暂未开放',
      icon: 'none'
    })
  },
  onShow() {
    this.getTabBar().init()
  }
})
