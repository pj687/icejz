const request = require('@/utils/request.js')

export const useUserInfoApi = () => {
  return request.get('/sys/user/info')
}

export const useUserInfoSubmitApi = (dataForm) => {
  return request.put('/sys/user/info', dataForm)
}

export const useUserAvatarApi = (dataForm) => {
  return request.put('/sys/user/avatar', dataForm)
}

export const updatePasswordApi = (data) => {
  return request.put('/sys/user/password', data)
}
