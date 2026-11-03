import service from '@/utils/request'

export const useMessageApi = (id: number) => {
	return service.get('/sys/message/' + id)
}

export const useMessageSubmitApi = (dataForm: any) => {
	return service.post('/sys/message', dataForm)
}

export const useMessageMyPageApi = (params?: any) => {
	return service.get('/sys/message/my/page', { params })
}

export const useMessageMyApi = (id: number) => {
	return service.get('/sys/message/my/' + id)
}

export const useMessageUnreadCountApi = () => {
	return service.get('/sys/message/my/unread-count')
}

export const useMessageLatestApi = (limit = 5) => {
	return service.get('/sys/message/my/latest', { params: { limit } })
}

export const useMessageReadApi = (id: number) => {
	return service.put('/sys/message/my/' + id + '/read')
}

export const useMessageReadAllApi = () => {
	return service.put('/sys/message/my/read-all')
}
