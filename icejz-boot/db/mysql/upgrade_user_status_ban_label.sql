-- 用户状态文案：停用 → 封禁
UPDATE sys_dict_data
SET dict_label = '封禁'
WHERE dict_type_id = (SELECT id FROM sys_dict_type WHERE dict_type = 'user_status' AND deleted = 0 LIMIT 1)
  AND dict_value = '0'
  AND deleted = 0;
