const request = require('@/utils/request.js')

export const useMessageMyPageApi = (params = {}) => {
  return request.get('/sys/message/my/page', params)
}

export const useMessageUnreadCountApi = () => {
  return request.get('/sys/message/my/unread-count')
}

export const useMessageMyApi = (id) => {
  return request.get('/sys/message/my/' + id)
}

export const useMessageReadApi = (id) => {
  return request.put('/sys/message/my/' + id + '/read')
}

export const useMessageReadAllApi = () => {
  return request.put('/sys/message/my/read-all')
}
