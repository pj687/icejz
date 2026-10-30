package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysDictDataEntity;
import net.icejz.system.query.SysDictDataQuery;
import net.icejz.system.vo.SysDictDataVO;

import java.util.List;

/**
 * 数据字典
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysDictDataService extends BaseService<SysDictDataEntity> {

    PageResult<SysDictDataVO> page(SysDictDataQuery query);

    void save(SysDictDataVO vo);

    void update(SysDictDataVO vo);

    void delete(List<Long> idList);

}