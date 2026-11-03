import constant from '@/utils/constant'
import { useAppStore } from '@/store/modules/app'

// 把路径转换成驼峰命名
export const pathToCamel = (path: string): string => {
	return path.replace(/\/(\w)/g, (all, letter) => letter.toUpperCase())
}

// 是否外链
export const isExternalLink = (url: string): boolean => {
	return /^(https?:|\/\/|http?:|\/\/|^{{\s?apiUrl\s?}})/.test(url)
}

// 替换外链参数
export const replaceLinkParam = (url: string): string => {
	return url.replace('{{apiUrl}}', constant.apiUrl)
}

// 转换文件大小格式
export const convertSizeFormat = (size: number): string => {
	const unit = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB']
	let index = Math.floor(Math.log(size) / Math.log(1024))
	let newSize = size / Math.pow(1024, index)

	// 保留的小数位数
	return newSize.toFixed(2) + ' ' + unit[index]
}

// 生成uuid
export const generateUUID = () => {
	let uuid = ''
	for (let i = 0; i < 32; i++) {
		let random = (Math.random() * 16) | 0
		if (i === 8 || i === 12 || i === 16 || i === 20) {
			uuid += '-'
		}
		uuid += (i === 12 ? 4 : i === 16 ? (random & 3) | 8 : random).toString(16)
	}
	return uuid
}

// 获取svg图标(id)列表
export const getIconList = (): string[] => {
	const rs: string[] = []
	const list = document.querySelectorAll('svg symbol[id^="icon-"]')
	for (let i = 0; i < list.length; i++) {
		rs.push(list[i].id)
	}
	return rs
}

// 获取字典Label
export const getDictLabel = (dictList: any[], dictType: string, dictValue: string) => {
	const type = dictList.find((element: any) => element.dictType === dictType)
	if (type) {
		const val = type.dataList.find((element: any) => element.dictValue === dictValue + '')
		if (val) {
			return val.dictLabel
		} else {
			return dictValue
		}
	} else {
		return dictValue
	}
}

// 获取字典Label样式
export const getDictLabelClass = (dictList: any[], dictType: string, dictValue: string): string => {
	const type = dictList.find((element: any) => element.dictType === dictType)
	if (type) {
		const val = type.dataList.find((element: any) => element.dictValue === dictValue + '')
		if (val) {
			return val.labelClass
		} else {
			return ''
		}
	} else {
		return ''
	}
}

export type DictLabelItem = {
	value: string
	label: string
	tone: string
}

const normalizeDictTone = (classStyle?: string) => {
	const tone = (classStyle || 'info').toLowerCase()
	if (['primary', 'success', 'warning', 'danger', 'info'].includes(tone)) {
		return tone
	}
	return 'info'
}

/** 字典标签结构化数据，供组件渲染美化令牌 */
export const getDictLabelItems = (dictType: string, dictValue: any): DictLabelItem[] => {
	if (dictValue === null || dictValue === undefined || dictValue === '') {
		return []
	}

	const valueText = typeof dictValue === 'number' || Number.isInteger(dictValue) ? String(dictValue) : String(dictValue)
	const appStore = useAppStore()

	return valueText
		.split(',')
		.map((value: string) => value.trim())
		.filter((value) => value !== '')
		.map((value: string) => {
			const classStyle = getDictLabelClass(appStore.dictList, dictType, value)
			const label = getDictLabel(appStore.dictList, dictType, value)
			return {
				value,
				label: String(label ?? value),
				tone: normalizeDictTone(classStyle)
			}
		})
}

export const getDictLabelList = (dictType: string, dictValue: any): string => {
	const items = getDictLabelItems(dictType, dictValue)
	return items
		.map((item) => `<span class="icejz-dict-tag tone-${item.tone}"><i class="dot"></i>${item.label}</span>`)
		.join(' ')
}

// 获取字典数据列表
export const getDictDataList = (dictList: any[], dictType: string) => {
	const type = dictList.find((element: any) => element.dictType === dictType)
	if (type) {
		return type.dataList
	} else {
		return []
	}
}

// 树形数据转换
export const treeDataTranslate = (data: any[], id?: string, pid?: string): any[] => {
	const res: any[] = []
	const temp: any = {}
	id = id || 'id'
	pid = pid || 'pid'
	for (let i = 0; i < data.length; i++) {
		temp[data[i][id]] = data[i]
	}
	for (let k = 0; k < data.length; k++) {
		if (!temp[data[k][pid]] || data[k][id] === data[k][pid]) {
			res.push(data[k])
			continue
		}
		if (!temp[data[k][pid]]['children']) {
			temp[data[k][pid]]['children'] = []
		}
		temp[data[k][pid]]['children'].push(data[k])
	}
	return res
}

// 生成数字字母混合字符串
export const getRandom = (num: number) => {
	const chars = [
		'0',
		'1',
		'2',
		'3',
		'4',
		'5',
		'6',
		'7',
		'8',
		'9',
		'a',
		'b',
		'c',
		'd',
		'e',
		'f',
		'g',
		'h',
		'i',
		'j',
		'k',
		'l',
		'm',
		'n',
		'o',
		'p',
		'q',
		'r',
		's',
		't',
		'u',
		'v',
		'w',
		'x',
		'y',
		'z'
	]
	let res = ''
	for (let i = 0; i < num; i++) {
		const id = Math.floor(Math.random() * 36)
		res += chars[id]
	}
	return res
}
