const request = require('@/utils/request.js')

export const useCaptchaEnabledApi = () => {
  return request.get('/sys/auth/captcha/enabled')
}

export const useCaptchaApi = () => {
  return request.get('/sys/auth/captcha')
}

/**
 * 登录接口
 */
export const useLoginApi = (data) => {
  return request.post('/sys/auth/login', data)
}

/**
 * 退出接口
 */
export const useLogoutApi = () => {
  return request.post('/sys/auth/logout')
}
