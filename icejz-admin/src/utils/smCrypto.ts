import { sm2 } from 'sm-crypto'

const publicKey = '0417b623de43a93a94bf272b4a19cfb796c1acce8a65bc818357ccf9022ffa4ac35748eb5a502a435ec93b45b0038b59d8df36542d38cc48a9a507fbb210a65019'

/**
 * sm2加密
 * @param data 待加密数据
 * @return 加密后的数据
 */
export const sm2Encrypt = (data: string): string => {
	return '04' + sm2.doEncrypt(data, publicKey, 1)
}
