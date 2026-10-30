const validateForm = (dataForm, rules) => {
  const errors = {}

  for (const field in rules) {
    if (rules.hasOwnProperty(field)) {
      const value = dataForm[field]
      // 表单数据里面不存在，则跳过
      if (value === undefined) {
        continue
      }

      const fieldRules = rules[field]
      for (const rule of fieldRules) {
        if (rule.required && value === '') {
          errors[field] = rule.message
          break
        }

        if (rule.pattern && !rule.pattern.test(value)) {
          errors[field] = rule.message
          break
        }
      }
    }
  }

  if (Object.keys(errors).length > 0) {
    for (const field in errors) {
      if (errors.hasOwnProperty(field)) {
        wx.showToast({
          title: errors[field],
          icon: 'none',
          duration: 2000
        })
        break // 只显示第一个错误提示
      }
    }
    return false
  }

  return true
}
export { validateForm }
