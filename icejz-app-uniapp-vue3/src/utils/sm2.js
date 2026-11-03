import { sm2 } from 'miniprogram-sm-crypto'

/**
 * 与管理端 / 后端 Sm2Util 保持一致的非压缩公钥（含 04 前缀）
 */
const PUBLIC_KEY =
	'0417b623de43a93a94bf272b4a19cfb796c1acce8a65bc818357ccf9022ffa4ac35748eb5a502a435ec93b45b0038b59d8df36542d38cc48a9a507fbb210a65019'

function normalizePublicKey(key) {
	const hex = String(key || '')
		.trim()
		.toLowerCase()
		.replace(/^0x/, '')
	if (!hex) return PUBLIC_KEY
	// 允许接口返回带/不带 04 的公钥
	if (hex.startsWith('04') && hex.length >= 130) return hex
	if (hex.length === 128) return `04${hex}`
	return PUBLIC_KEY
}

/**
 * SM2 加密（C1C3C2），输出与管理端一致：04 + hex
 * @param {string} data 明文
 * @returns {string} 密文 hex
 */
export const sm2Encrypt = (data) => {
	const plain = data == null ? '' : String(data)
	if (!plain) {
		throw new Error('待加密内容不能为空')
	}
	// cipherMode=1 → C1C3C2，与 hutool SM2 默认一致
	const cipherHex = sm2.doEncrypt(plain, normalizePublicKey(PUBLIC_KEY), 1)
	// sm-crypto 密文不含 04，后端解密需要补上
	return cipherHex.startsWith('04') ? cipherHex : `04${cipherHex}`
}

/** @deprecated 兼容旧调用；公钥已内置，无需异步拉取 */
export const getPublicKey = async () => PUBLIC_KEY
