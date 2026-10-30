import service from '@/utils/request'

export type WorkbenchNoteType = 'memo' | 'nudge' | 'remind'

export type WorkbenchNote = {
	id?: number
	noteDate: string
	noteType: WorkbenchNoteType | string
	content: string
	createTime?: string
}

export const useWorkbenchNoteListApi = (yearMonth?: string) => {
	return service.get('/sys/workbench/note/list', {
		params: yearMonth ? { yearMonth } : undefined
	})
}

export const useWorkbenchNoteSaveApi = (data: WorkbenchNote) => {
	return service.post('/sys/workbench/note', data)
}

export const useWorkbenchNoteDeleteApi = (idList: number[]) => {
	return service.delete('/sys/workbench/note', { data: idList })
}
