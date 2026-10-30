import service from '@/utils/request'

export type AppVersionInfo = {
	name: string
	version: string
	application?: string
}

export const useAppVersionApi = () => {
	return service.get('/sys/app/version')
}
