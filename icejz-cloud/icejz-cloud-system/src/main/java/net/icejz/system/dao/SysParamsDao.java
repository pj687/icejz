package net.icejz.system.dao;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysParamsEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 参数管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Mapper
public interface SysParamsDao extends BaseDao<SysParamsEntity> {

    default boolean isExist(String paramKey) {
        return this.exists(new QueryWrapper<SysParamsEntity>().eq("param_key", paramKey));
    }

    default SysParamsEntity get(String paramKey) {
        return this.selectOne(new QueryWrapper<SysParamsEntity>().eq("param_key", paramKey));
    }
}