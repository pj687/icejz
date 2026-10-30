const TOKEN_KEY = 'token';
const USER_INFO_KEY = 'userInfo';

const cache = {
    // 设置token
    setToken(token) {
        uni.setStorageSync(TOKEN_KEY, token);
    },

    // 获取token
    getToken() {
        return uni.getStorageSync(TOKEN_KEY);
    },

    // 移除token
    removeToken() {
        uni.removeStorageSync(TOKEN_KEY);
    },

    // 设置用户信息
    setUserInfo(userInfo) {
        uni.setStorageSync(USER_INFO_KEY, userInfo);
    },

    // 获取用户信息
    getUserInfo() {
        return uni.getStorageSync(USER_INFO_KEY);
    },

    // 移除用户信息
    removeUserInfo() {
        uni.removeStorageSync(USER_INFO_KEY);
    },

    // 清除所有缓存
    clear() {
        uni.clearStorageSync();
    },

    // 设置缓存
    set(key, value) {
        uni.setStorageSync(key, value);
    },

    // 获取缓存
    get(key) {
        return uni.getStorageSync(key);
    },

    // 移除缓存
    remove(key) {
        uni.removeStorageSync(key);
    }
};

export default cache;
