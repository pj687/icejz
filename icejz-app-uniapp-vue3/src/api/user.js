import * as request from '../utils/request.js'

/** 获取用户信息 */
export const useUserInfoApi = () => {
  return request.get('/sys/user/info')
}

/** 更新用户信息 */
export const useUserInfoSubmitApi = (dataForm) => {
  return request.put('/sys/user/info', dataForm)
}

/** 更新用户头像 */
export const useUserAvatarApi = (dataForm) => {
  return request.put('/sys/user/avatar', dataForm)
}

/** 修改密码 */
export const updatePasswordApi = (data) => {
  return request.put('/sys/user/password', data)
}

/** 当前用户登录设备列表 */
export const useUserDeviceListApi = () => {
  return request.get('/sys/user/device')
}

/** 下线指定登录设备 */
export const useUserDeviceKickApi = (accessToken) => {
  return request.del('/sys/user/device/' + encodeURIComponent(accessToken))
}

/** 当前用户多设备登录设置 */
export const useMyLoginSecurityApi = () => {
  return request.get('/sys/user/login-security')
}

/** 保存当前用户多设备登录设置 */
export const useMyLoginSecuritySaveApi = (data) => {
  return request.put('/sys/user/login-security', data)
}

/** @deprecated 兼容旧引用，请改用 @/api/message.js */
export const useNoticePageApi = (params) => request.get('/sys/message/my/page', params)
export const useNoticeUnreadCountApi = () => request.get('/sys/message/my/unread-count')
export const useNoticeReadApi = (id) => request.put(`/sys/message/my/${id}/read`)
export const useNoticeReadAllApi = () => request.put('/sys/message/my/read-all')
export const useNoticeDetailApi = (id) => request.get(`/sys/message/my/${id}`)
