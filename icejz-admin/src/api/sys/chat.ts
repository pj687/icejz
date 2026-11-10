import service from '@/utils/request'

export const useChatConversationPageApi = (params: any) => {
	return service.get('/sys/chat/conversation/page', { params })
}

export const useChatConversationInfoApi = (id: number | string) => {
	return service.get('/sys/chat/conversation/' + id)
}

export const useChatMembersApi = (id: number | string) => {
	return service.get('/sys/chat/conversation/' + id + '/members')
}

export const useChatDirectApi = (data: { userId: number }) => {
	return service.post('/sys/chat/conversation/direct', data)
}

export const useChatGroupApi = (data: { title: string; avatar?: string; memberIds: number[] }) => {
	return service.post('/sys/chat/conversation/group', data)
}

export const useChatAddMembersApi = (data: any) => {
	return service.post('/sys/chat/conversation/members', data)
}

export const useChatRemoveMembersApi = (data: any) => {
	return service.delete('/sys/chat/conversation/members', { data })
}

export const useChatDissolveApi = (id: number | string) => {
	return service.put('/sys/chat/conversation/' + id + '/dissolve')
}

export const useChatReadApi = (id: number | string) => {
	return service.put('/sys/chat/conversation/' + id + '/read')
}

export const useChatMessagePageApi = (params: any) => {
	return service.get('/sys/chat/message/page', { params })
}

export const useChatSendApi = (data: any) => {
	return service.post('/sys/chat/message', data)
}

export const useChatRecallApi = (id: number | string) => {
	return service.put('/sys/chat/message/' + id + '/recall')
}

export const useChatUnreadCountApi = () => {
	return service.get('/sys/chat/unread-count')
}

export const useChatPeerPageApi = (params: any) => {
	return service.get('/sys/chat/peer/page', { params })
}

export const useChatAllowPageApi = (params: any) => {
	return service.get('/sys/chat/allow/page', { params })
}

export const useChatAllowSubmitApi = (dataForm: any) => {
	if (dataForm.id) {
		return service.put('/sys/chat/allow', dataForm)
	}
	return service.post('/sys/chat/allow', dataForm)
}

export const useChatAllowDeleteApi = (idList: number[]) => {
	return service.delete('/sys/chat/allow', { data: idList })
}
