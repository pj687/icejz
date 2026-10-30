package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysParamsEntity;
import net.icejz.system.query.SysParamsQuery;
import net.icejz.system.vo.SysParamsVO;

import java.util.List;

/**
 * 参数管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysParamsService extends BaseService<SysParamsEntity> {

    PageResult<SysParamsVO> page(SysParamsQuery query);

    void save(SysParamsVO vo);

    void update(SysParamsVO vo);

    void delete(List<Long> idList);

    /**
     * 根据paramKey，获取字符串值
     *
     * @param paramKey 参数Key
     */
    String getString(String paramKey);

    /**
     * 根据paramKey，获取整型值
     *
     * @param paramKey 参数Key
     */
    int getInt(String paramKey);

    /**
     * 根据paramKey，获取布尔值
     *
     * @param paramKey 参数Key
     */
    boolean getBoolean(String paramKey);

    /**
     * 根据paramKey，获取对象值
     *
     * @param paramKey  参数Key
     * @param valueType 类型
     */
    <T> T getJSONObject(String paramKey, Class<T> valueType);
}