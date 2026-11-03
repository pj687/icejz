import type { App } from 'vue'
import { useUserStore } from '@/store/modules/user'

const hasAuth = (authorityList: string[], value: unknown) => {
	if (value == null || value === '') {
		return true
	}
	const required = Array.isArray(value) ? value : [value]
	return required.some(code => authorityList.some(v => v === code))
}

export function auth(app: App) {
	// 权限验证：支持字符串或字符串数组（任一命中即可）
	app.directive('auth', {
		mounted(el, binding) {
			const userStore = useUserStore()
			if (!hasAuth(userStore.authorityList || [], binding.value)) {
				el.parentNode?.removeChild(el)
			}
		}
	})
}
