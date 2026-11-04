import * as request from '../utils/request.js'

export const useWorkbenchNoteListApi = (yearMonth) => {
  const params = yearMonth ? { yearMonth } : {}
  return request.get('/sys/workbench/note/list', params)
}

export const useWorkbenchNoteSaveApi = (data) => {
  return request.post('/sys/workbench/note', data)
}

export const useWorkbenchNoteDeleteApi = (idList) => {
  return request.del('/sys/workbench/note', idList)
}
