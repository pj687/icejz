const cache = require('@/utils/cache.js')

const baseUrl = 'https://demo.icejz.net/icejz-boot-server'
// const baseUrl = 'http://192.168.101.86:8080'

const request = (method, url, data = {}, header = {}) => {
  // 如果token存在，则设置token
  if (cache.getToken()) {
    header.Authorization = cache.getToken()
  }

  return new Promise((resolve, reject) => {
    wx.request({
      url: `${baseUrl}${url}`,
      method: method,
      data: data,
      header: header,
      success: (res) => {
        // 处理响应
        response(res.data, resolve, reject)
      },
      fail: (err) => {
        reject(err)
      }
    })
  })
}

const upload = (url, filePath, name, formData = {}, header = {}) => {
  // 如果token存在，则设置token
  if (cache.getToken()) {
    header.Authorization = cache.getToken()
  }

  return new Promise((resolve, reject) => {
    wx.uploadFile({
      url: `${baseUrl}${url}`,
      filePath: filePath,
      name: name || 'file',
      formData: formData,
      header: header,
      success: (res) => {
        // 处理响应
        response(JSON.parse(res.data), resolve, reject)
      },
      fail: (err) => {
        reject(err)
      }
    })
  })
}

const response = (data, resolve, reject) => {
  if (data.code === 0) {
    resolve(data)
    return
  }

  // 未登录或token失效
  if (data.code === 401) {
    cache.removeToken()

    // 跳转到登录页
    wx.reLaunch({
      url: '/pages/login/login'
    })
    return
  }

  wx.showToast({
    title: data.msg,
    icon: 'none',
    duration: 2000
  })

  reject(data)
}

const get = (url, data = {}, header = {}) => {
  // 为了防止缓存，携带时间戳
  data.t = new Date().getTime()
  return request('GET', url, data, header)
}

const post = (url, data = {}, header = {}) => {
  return request('POST', url, data, header)
}

const put = (url, data = {}, header = {}) => {
  return request('PUT', url, data, header)
}

const del = (url, data = {}, header = {}) => {
  return request('DELETE', url, data, header)
}

export { get, post, put, del, upload }
