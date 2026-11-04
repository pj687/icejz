const { get, post, del } = require('@/utils/request.js')

const useWorkbenchNoteListApi = (yearMonth) => {
  const params = yearMonth ? { yearMonth } : {}
  return get('/sys/workbench/note/list', params)
}

const useWorkbenchNoteSaveApi = (data) => {
  return post('/sys/workbench/note', data)
}

const useWorkbenchNoteDeleteApi = (idList) => {
  return del('/sys/workbench/note', idList)
}

module.exports = {
  useWorkbenchNoteListApi,
  useWorkbenchNoteSaveApi,
  useWorkbenchNoteDeleteApi
}
