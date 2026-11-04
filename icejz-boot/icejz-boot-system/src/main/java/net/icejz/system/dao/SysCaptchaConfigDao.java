package net.icejz.system.dao;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysCaptchaConfigEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 验证码配置
 */
@Mapper
public interface SysCaptchaConfigDao extends BaseDao<SysCaptchaConfigEntity> {

    default SysCaptchaConfigEntity getByTenantId(Long tenantId) {
        return this.selectOne(new QueryWrapper<SysCaptchaConfigEntity>()
                .eq("tenant_id", tenantId)
                .last("LIMIT 1"));
    }
}
