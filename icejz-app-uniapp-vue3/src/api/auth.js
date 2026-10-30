import * as request from '../utils/request.js';

export const useCaptchaEnabledApi = () => {
    return request.get('/sys/auth/captcha/enabled');
};

export const useCaptchaApi = () => {
    return request.get('/sys/auth/captcha');
};

export const usePublicKeyApi = () => {
    return request.get('/sys/auth/public-key');
};

/**
 * 账号登录接口
 */
export const useLoginApi = (data) => {
    return request.post('/sys/auth/login', data);
};

/**
 * 发送手机验证码
 */
export const useSendCodeApi = (mobile) => {
    return request.post(`/sys/auth/send/code?mobile=${mobile}`);
};

/**
 * 手机验证码登录接口
 */
export const useMobileLoginApi = (data) => {
    return request.post('/sys/auth/mobile', data);
};

/**
 * 首次登录完善信息
 */
export const useCompleteProfileApi = (data) => {
    return request.post('/sys/auth/complete-profile', data);
};

/**
 * 退出接口
 */
export const useLogoutApi = () => {
    return request.post('/sys/auth/logout');
};
