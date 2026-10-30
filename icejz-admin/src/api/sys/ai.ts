import service from '@/utils/request'

export const useAiModelApi = (id: number) => {
	return service.get('/sys/ai/model/' + id)
}

export const useAiModelSubmitApi = (dataForm: any) => {
	if (dataForm.id) {
		return service.put('/sys/ai/model', dataForm)
	}
	return service.post('/sys/ai/model', dataForm)
}

export const useAiModelListApi = () => {
	return service.get('/sys/ai/model/list')
}

export const useAiModelEnabledListApi = () => {
	return service.get('/sys/ai/model/enabled')
}

export const useAiRobotInfoApi = () => {
	return service.get('/sys/ai/robot/info')
}

export const useAiRobotSaveApi = (dataForm: any) => {
	return service.put('/sys/ai/robot', dataForm)
}

export const useAiChatApi = (data: {
	message: string
	modelId?: number | null
	sessionId?: number | null
	history?: Array<{ role: string; content: string }>
}) => {
	return service.post('/sys/ai/chat', data)
}

export type AiChatSession = {
	id: number
	title: string
	lastMsgTime?: string
	createTime?: string
}

export type AiChatMessage = {
	id?: number
	sessionId?: number
	role: 'user' | 'assistant' | string
	content: string
	createTime?: string
}

export const useAiChatSessionListApi = () => {
	return service.get('/sys/ai/chat/session/list')
}

export const useAiChatSessionMessagesApi = (id: number) => {
	return service.get('/sys/ai/chat/session/' + id + '/messages')
}

export const useAiChatSessionCreateApi = (title?: string) => {
	return service.post('/sys/ai/chat/session', title ? { title } : {})
}

export const useAiChatSessionDeleteApi = (idList: number[]) => {
	return service.delete('/sys/ai/chat/session', { data: idList })
}

export const useAiModelTestApi = (id: number) => {
	return service.post('/sys/ai/model/test/' + id)
}
