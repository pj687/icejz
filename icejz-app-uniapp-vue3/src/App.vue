<script>
import { installIceToast } from '@/utils/iceToast.js'

export default {
  data() {
    return {}
  },
  onLaunch() {
    installIceToast()
    this.hideNativeTabBar()
  },
  onShow() {
    installIceToast()
    this.hideNativeTabBar()
    // 版本更新（仅 App/小程序端支持，H5 没有该 API）
    if (typeof uni.getUpdateManager !== 'function') return
    const updateManager = uni.getUpdateManager()
    updateManager.onCheckForUpdate(function () {})
    updateManager.onUpdateReady(() => {
      uni.showModal({
        title: this.$t('update.title'),
        content: this.$t('update.content'),
        success: function (res) {
          if (res.confirm) {
            updateManager.applyUpdate()
          }
        }
      })
    })
  },
  methods: {
    hideNativeTabBar() {
      // 启动页/登录页等非 tab 页调用 hideTabBar 会抛：
      // hideTabBar:fail not TabBar page（H5 为未捕获 Promise，可能影响后续页面）
      // H5 已用 CSS 隐藏原生 tabBar，直接跳过 API
      // #ifdef H5
      return
      // #endif

      try {
        const pages = typeof getCurrentPages === 'function' ? getCurrentPages() : []
        const route = pages[pages.length - 1]?.route || ''
        const tabRoutes = ['pages/index/index', 'pages/workbench/workbench', 'pages/usercenter/usercenter']
        // onLaunch 时尚无页面，或当前不在 tab 页时不要调用
        if (!route || !tabRoutes.includes(route)) return
        const ret = uni.hideTabBar({
          animation: false,
          fail() {},
          complete() {}
        })
        // 兼容返回 Promise 的运行时，避免 Uncaught (in promise)
        if (ret && typeof ret.then === 'function') {
          ret.then(() => {}, () => {})
        }
      } catch (e) {
        // ignore
      }
    }
  },
  globalData: {}
}
</script>

<style>
@import './style/theme.css';
.container {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-between;
  padding: 200rpx 0;
  box-sizing: border-box;
}

.require::after {
  content: '*';
  color: red;
  font-size: 32rpx;
  margin-left: 4rpx;
}

/* H5：隐藏原生 tabBar 占位，只保留自定义浮动导航 */
/* #ifdef H5 */
uni-tabbar,
.uni-tabbar,
.uni-tabbar-bottom {
  display: none !important;
  height: 0 !important;
  min-height: 0 !important;
  opacity: 0 !important;
  pointer-events: none !important;
}

.uni-app--showtabbar uni-page-wrapper::after,
.uni-app--showtabbar uni-page-body::after {
  display: none !important;
  height: 0 !important;
  content: none !important;
}
/* #endif */
</style>
