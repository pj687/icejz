package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysPostEntity;
import net.icejz.system.query.SysPostQuery;
import net.icejz.system.vo.SysPostVO;

import java.util.List;

/**
 * 岗位管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysPostService extends BaseService<SysPostEntity> {

    PageResult<SysPostVO> page(SysPostQuery query);

    List<SysPostVO> getList();

    List<String> getNameList(List<Long> idList);

    void save(SysPostVO vo);

    void update(SysPostVO vo);

    void delete(List<Long> idList);
}