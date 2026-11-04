import { get, post, del } from '@/utils/request.js'

export const useAiRobotInfoApi = () => {
  return get('/sys/ai/robot/info')
}

export const useAiModelEnabledListApi = () => {
  return get('/sys/ai/model/enabled')
}

/** LLM 调用较慢，单独加长超时 */
export const useAiChatApi = (data) => {
  return post('/sys/ai/chat', data, {}, { timeout: 60000 })
}

export const useAiChatSessionListApi = () => {
  return get('/sys/ai/chat/session/list')
}

export const useAiChatSessionMessagesApi = (id) => {
  return get(`/sys/ai/chat/session/${id}/messages`)
}

export const useAiChatSessionCreateApi = (title) => {
  return post('/sys/ai/chat/session', title ? { title } : {})
}

export const useAiChatSessionDeleteApi = (idList) => {
  return del('/sys/ai/chat/session', idList)
}
