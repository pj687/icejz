import * as request from '../utils/request.js';

export const useCaptchaEnabledApi = () => {
    return request.get('/sys/auth/captcha/enabled');
};

/** channel: pc | app | sms */
export const useCaptchaApi = (channel = 'app') => {
    return request.get('/sys/auth/captcha', { channel });
};

/** 交互验证码预校验（不消耗验证码，登录/发短信时再正式校验） */
export const useCaptchaCheckApi = (data) => {
    return request.post('/sys/auth/captcha/check', data);
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
 * 发送手机验证码（需先通过图形验证码）
 */
export const useSendCodeApi = (data) => {
    return request.post('/sys/auth/send/code', data);
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
