<script>
export default {
    data() {
        return {};
    },
    onLaunch() {},
    onShow() {
        // 版本更新（仅 App/小程序端支持，H5 没有该 API）
        if (typeof uni.getUpdateManager !== 'function') return;
        const updateManager = uni.getUpdateManager();
        updateManager.onCheckForUpdate(function (res) {
            // 请求完新版本信息的回调
            // console.log(res.hasUpdate)
        });
        updateManager.onUpdateReady(function () {
            uni.showModal({
                title: '更新提示',
                content: '新版本已经准备好，是否重启应用？',
                success: function (res) {
                    if (res.confirm) {
                        updateManager.applyUpdate();
                    }
                }
            });
        });
    },
    globalData: {}
};
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
</style>
