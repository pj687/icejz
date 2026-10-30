const validateForm = (dataForm, rules) => {
    const errors = [];
    for (const field in rules) {
        if (rules.hasOwnProperty(field)) {
            const value = dataForm[field];
            // 表单数据里面不存在，则跳过
            if (value === undefined) {
                continue;
            }
            const fieldRules = rules[field];
            
            // 处理单个规则对象
            if (fieldRules.required && value === '') {
                errors.push(fieldRules.message);
                break;
            }
            if (fieldRules.pattern && !fieldRules.pattern.test(value)) {
                errors.push(fieldRules.message);
                break;
            }
            
            // 处理规则数组
            if (Array.isArray(fieldRules)) {
                for (const rule of fieldRules) {
                    if (rule.required && value === '') {
                        errors.push(rule.message);
                        break;
                    }
                    if (rule.pattern && !rule.pattern.test(value)) {
                        errors.push(rule.message);
                        break;
                    }
                }
            }
        }
    }
    
    return errors;
};
export { validateForm };
