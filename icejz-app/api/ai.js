const request = require('@/utils/request.js')

export const useAiRobotInfoApi = () => {
  return request.get('/sys/ai/robot/info')
}

export const useAiModelEnabledListApi = () => {
  return request.get('/sys/ai/model/enabled')
}

/** LLM 调用较慢，单独加长超时 */
export const useAiChatApi = (data) => {
  return request.post('/sys/ai/chat', data, {}, { timeout: 60000 })
}

export const useAiChatSessionListApi = () => {
  return request.get('/sys/ai/chat/session/list')
}

export const useAiChatSessionMessagesApi = (id) => {
  return request.get('/sys/ai/chat/session/' + id + '/messages')
}

export const useAiChatSessionCreateApi = (title) => {
  return request.post('/sys/ai/chat/session', title ? { title } : {})
}

export const useAiChatSessionDeleteApi = (idList) => {
  return request.del('/sys/ai/chat/session', idList)
}
