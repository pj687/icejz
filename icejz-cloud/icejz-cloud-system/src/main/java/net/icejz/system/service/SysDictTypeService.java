package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysDictTypeEntity;
import net.icejz.system.query.SysDictTypeQuery;
import net.icejz.system.vo.SysDictTypeVO;
import net.icejz.system.vo.SysDictVO;

import java.util.List;

/**
 * 数据字典
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysDictTypeService extends BaseService<SysDictTypeEntity> {

    PageResult<SysDictTypeVO> page(SysDictTypeQuery query);

    List<SysDictTypeVO> list(Long pid);

    void save(SysDictTypeVO vo);

    void update(SysDictTypeVO vo);

    void delete(List<Long> idList);

    /**
     * 获取动态SQL数据
     */
    List<SysDictVO.DictData> getDictSql(Long id);

    /**
     * 获取全部字典列表
     */
    List<SysDictVO> getDictList();

    /**
     * 刷新字典缓存
     */
    void refreshTransCache();

}