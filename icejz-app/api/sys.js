const request = require('@/utils/request.js')

export const useUserPageApi = (params = {}) => {
  return request.get('/sys/user/page', params)
}

export const useOrgListApi = () => {
  return request.get('/sys/org/list')
}

export const useRolePageApi = (params = {}) => {
  return request.get('/sys/role/page', params)
}

export const useRoleListApi = () => {
  return request.get('/sys/role/list')
}
