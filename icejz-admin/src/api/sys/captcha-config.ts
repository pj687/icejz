import service from '@/utils/request'

export const useCaptchaConfigApi = () => {
	return service.get('/sys/captcha/config')
}

export const useCaptchaConfigSaveApi = (data: any) => {
	return service.put('/sys/captcha/config', data)
}
