import cache from './cache.js';
const baseUrl = 'http://localhost:8080';

const request = (method, url, data = {}, header = {}, options = {}) => {
    // 如果token存在，则设置token
    if (cache.getToken()) {
        header.Authorization = cache.getToken();
    }
    
    const fullUrl = `${baseUrl}${url}`;
    // console.log(`[API Request] ${method} ${fullUrl}`, { data, header });
    
    return new Promise((resolve, reject) => {
        uni.request({
            url: fullUrl,
            method: method,
            data: data,
            header: header,
            timeout: options.timeout || 10000,
            success: (res) => {
                // console.log(`[API Response] ${method} ${fullUrl}`, res);
                // 处理响应
                response(res.data, resolve, reject);
            },
            fail: (err) => {
                console.error(`[API Error] ${method} ${fullUrl}`, err);
                reject(err);
            }
        });
    });
};
const upload = (url, filePath, name, formData = {}, header = {}) => {
    // 如果token存在，则设置token
    if (cache.getToken()) {
        header.Authorization = cache.getToken();
    }
    return new Promise((resolve, reject) => {
        uni.uploadFile({
            url: `${baseUrl}${url}`,
            filePath: filePath,
            name: name || 'file',
            formData: formData,
            header: header,
            success: (res) => {
                // 处理响应
                response(JSON.parse(res.data), resolve, reject);
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};
const response = (data, resolve, reject) => {
    if (data.code === 0) {
        resolve(data);
        return;
    }

    // 未登录或token失效
    if (data.code === 401) {
        cache.removeToken();

        // 跳转到登录页
        uni.reLaunch({
            url: '/pages/login/login'
        });
        return;
    }
    uni.showToast({
        title: data.msg,
        icon: 'none',
        duration: 2000
    });
    reject(data);
};
const get = (url, data = {}, header = {}, options = {}) => {
    // 为了防止缓存，携带时间戳
    data.t = new Date().getTime();
    return request('GET', url, data, header, options);
};
const post = (url, data = {}, header = {}, options = {}) => {
    return request('POST', url, data, header, options);
};
const put = (url, data = {}, header = {}, options = {}) => {
    return request('PUT', url, data, header, options);
};
const del = (url, data = {}, header = {}, options = {}) => {
    return request('DELETE', url, data, header, options);
};
export { get, post, put, del, upload };
