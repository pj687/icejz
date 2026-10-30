import { sm2 } from 'miniprogram-sm-crypto';
import { usePublicKeyApi } from '../api/auth.js';
import cache from './cache.js';

const PUBLIC_KEY_CACHE_KEY = 'sm2PublicKey';
const DEFAULT_PUBLIC_KEY = '0417b623de43a93a94bf272b4a19cfb796c1acce8a65bc818357ccf9022ffa4ac35748eb5a502a435ec93b45b0038b59d8df36542d38cc48a9a507fbb210a65019';

export const getPublicKey = async () => {
    const cached = cache.get(PUBLIC_KEY_CACHE_KEY);
    if (cached) {
        return cached;
    }

    try {
        const response = await usePublicKeyApi();
        const publicKey = response?.data || DEFAULT_PUBLIC_KEY;
        cache.set(PUBLIC_KEY_CACHE_KEY, publicKey);
        return publicKey;
    } catch (error) {
        return DEFAULT_PUBLIC_KEY;
    }
};

/**
 * sm2加密
 * @param data 待加密数据
 * @return 加密后的数据
 */
export const sm2Encrypt = async (data) => {
    const publicKey = await getPublicKey();
    return '04' + sm2.doEncrypt(data, publicKey, 1);
};
