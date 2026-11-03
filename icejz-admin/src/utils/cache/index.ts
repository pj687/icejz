import { SessionStorage, Storage } from '@/utils/storage'
import CacheKey from '@/utils/cache/key'
import { ITheme } from '@/store/theme/interface'
import { themeConfig } from '@/store/theme/config'

// 缓存
class Cache {
	getToken = (): string => {
		return Storage.getItem(CacheKey.TokenKey) || ''
	}

	setToken = (value: string) => {
		Storage.setItem(CacheKey.TokenKey, value)
	}

	getTenantId = (): string => {
		return Storage.getItem(CacheKey.TenantId) || ''
	}

	setTenantId = (value: string) => {
		Storage.setItem(CacheKey.TenantId, value)
	}

	getRefreshToken = (): string => {
		return Storage.getItem(CacheKey.RefreshTokenKey) || ''
	}

	setRefreshToken = (value: string) => {
		Storage.setItem(CacheKey.RefreshTokenKey, value)
	}

	getSidebarOpened = (): boolean => {
		return Storage.getItem(CacheKey.SidebarOpenedKey) || false
	}

	setSidebarOpened = (value: boolean) => {
		Storage.setItem(CacheKey.SidebarOpenedKey, value)
	}

	getLanguage = (): string => {
		return Storage.getItem(CacheKey.LangKey) || 'zh-CN'
	}

	setLanguage = (value: string) => {
		Storage.setItem(CacheKey.LangKey, value)
	}

	getComponentSize = (): string => {
		return Storage.getItem(CacheKey.ComponentSizeKey) || 'default'
	}

	setComponentSize = (value: string) => {
		Storage.setItem(CacheKey.ComponentSizeKey, value)
	}

	getTheme = (): ITheme => {
		// 优先读取本地持久化配置；兼容旧版 session 缓存
		const localTheme = Storage.getItem(CacheKey.ThemeKey) as ITheme | null
		if (localTheme) {
			return { ...themeConfig, ...localTheme }
		}
		const sessionTheme = SessionStorage.getItem(CacheKey.ThemeKey) as ITheme | null
		if (sessionTheme) {
			Storage.setItem(CacheKey.ThemeKey, sessionTheme)
			SessionStorage.removeItem(CacheKey.ThemeKey)
			return { ...themeConfig, ...sessionTheme }
		}
		return { ...themeConfig }
	}

	setTheme = (value: ITheme) => {
		Storage.setItem(CacheKey.ThemeKey, value)
		SessionStorage.removeItem(CacheKey.ThemeKey)
	}

	removeTheme = () => {
		Storage.removeItem(CacheKey.ThemeKey)
		SessionStorage.removeItem(CacheKey.ThemeKey)
	}

	getRedirect = (): string => {
		return Storage.getItem(CacheKey.Redirect)
	}

	setRedirect = (value: string) => {
		Storage.setItem(CacheKey.Redirect, value)
	}

	clearRedirect = () => {
		Storage.removeItem(CacheKey.Redirect)
	}
}

export default new Cache()
