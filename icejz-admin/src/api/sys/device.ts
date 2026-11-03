import service from '@/utils/request'

export const useUserDeviceListApi = () => {
	return service.get('/sys/user/device')
}

export const useUserDeviceKickApi = (accessToken: string) => {
	return service.delete('/sys/user/device/' + accessToken)
}

export const useMyLoginSecurityApi = () => {
	return service.get('/sys/user/login-security')
}

export const useMyLoginSecuritySaveApi = (data: {
	multiDeviceLogin: number | null
	multiDeviceMax: number | null
}) => {
	return service.put('/sys/user/login-security', data)
}
