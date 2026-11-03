import service from '@/utils/request'

export const useCaptchaEnabledApi = () => {
	return service.get('/sys/auth/captcha/enabled')
}

export const useCaptchaApi = (channel: string = 'pc') => {
	return service.get('/sys/auth/captcha', { params: { channel } })
}

/** 滑动拼图松手预校验（不消费），返回 data: boolean */
export const useCaptchaCheckApi = (data: { key: string; captcha: string }) => {
	return service.post('/sys/auth/captcha/check', data)
}

export const useSendCodeApi = (data: { mobile: string; key: string; captcha: string }) => {
	return service.post('/sys/auth/send/code', data)
}

export const useAccountLoginApi = (data: any) => {
	return service.post('/sys/auth/login', data)
}

export const useMobileLoginApi = (data: any) => {
	return service.post('/sys/auth/mobile', data)
}

export const useThirdLoginApi = (data: any) => {
	return service.post('/sys/auth/third', data)
}

export const useLogoutApi = () => {
	return service.post('/sys/auth/logout')
}
