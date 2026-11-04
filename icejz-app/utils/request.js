const cache = require('@/utils/cache.js')

// 与管理端一致，默认联调本地 boot；线上改为 demo 地址
const baseUrl = 'http://localhost:8080'
// const baseUrl = 'https://demo.icejz.net/icejz-boot-server'

const request = (method, url, data = {}, header = {}, options = {}) => {
  if (cache.getToken()) {
    header.Authorization = cache.getToken()
  }

  return new Promise((resolve, reject) => {
    wx.request({
      url: `${baseUrl}${url}`,
      method: method,
      data: data,
      header: header,
      timeout: options.timeout || 15000,
      success: (res) => {
        response(res.data, resolve, reject)
      },
      fail: (err) => {
        reject(err)
      }
    })
  })
}

const upload = (url, filePath, name, formData = {}, header = {}) => {
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

  if (data.code === 401) {
    cache.removeToken()
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

const get = (url, data = {}, header = {}, options = {}) => {
  data.t = new Date().getTime()
  return request('GET', url, data, header, options)
}

const post = (url, data = {}, header = {}, options = {}) => {
  return request('POST', url, data, {
    'content-type': 'application/json',
    ...header
  }, options)
}

const put = (url, data = {}, header = {}, options = {}) => {
  return request('PUT', url, data, header, options)
}

const del = (url, data = {}, header = {}, options = {}) => {
  return request('DELETE', url, data, header, options)
}

export { get, post, put, del, upload }
