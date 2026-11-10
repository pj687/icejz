import service from '@/utils/request'

/** clientType: 0 PC / 1 APP / 2 小程序 */
export const useMenuNavApi = (clientType: number = 0) => {
	return service.get('/sys/menu/nav', { params: { clientType } })
}

export const useAuthorityListApi = () => {
	return service.get('/sys/menu/authority')
}

export const useMenuListApi = (type: Number, clientType?: number | null) => {
	// 菜单类型 0：菜单  1：按钮  2：接口
	const menuType = type === 2 ? 2 : 0
	const params: Record<string, number> = { type: menuType as number }
	if (clientType !== undefined && clientType !== null) {
		params.clientType = clientType
	}
	return service.get('/sys/menu/list', { params })
}

export const useMenuApi = (id: Number) => {
	return service.get('/sys/menu/' + id)
}

export const useMenuSubmitApi = (dataForm: any) => {
	if (dataForm.id) {
		return service.put('/sys/menu', dataForm)
	} else {
		return service.post('/sys/menu', dataForm)
	}
}
