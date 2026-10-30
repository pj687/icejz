const tokenKey = 'token'
const userInfoKey = 'userInfo'

const setToken = (token) => {
  wx.setStorageSync(tokenKey, token)
}

const getToken = () => {
  return wx.getStorageSync(tokenKey)
}

/**
 * 移除本地存储中的 token。
 * 该函数用于清除用户认证信息，通常在用户登出或需要重置认证状态时调用。
 * @function removeToken
 */
const removeToken = () => {
  wx.removeStorageSync(tokenKey)
}

const setUserInfo = (userInfo) => {
  wx.setStorageSync(userInfoKey, userInfo)
}

const getUserInfo = () => {
  return wx.getStorageSync(userInfoKey)
}

const removeUserInfo = () => {
  wx.removeStorageSync(userInfoKey)
}

export { setToken, getToken, removeToken, setUserInfo, getUserInfo, removeUserInfo }
