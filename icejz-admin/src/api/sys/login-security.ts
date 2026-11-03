import service from '@/utils/request'

export const useLoginSecurityConfigApi = () => {
	return service.get('/sys/login/security')
}

export const useLoginSecurityConfigSaveApi = (data: any) => {
	return service.put('/sys/login/security', data)
}
