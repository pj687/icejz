import { sm2 } from 'miniprogram-sm-crypto';
import { usePublicKeyApi } from '../api/auth.js';
import cache from './cache.js';

const PUBLIC_KEY_CACHE_KEY = 'sm2PublicKey';
const DEFAULT_PUBLIC_KEY = '040a302b5e4b961afb3908a4ae191266ac5866be100fc52e3b8dba9707c8620e64ae790ceffc3bfbf262dc098d293dd3e303356cb91b54861c767997799d2f0060';

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
