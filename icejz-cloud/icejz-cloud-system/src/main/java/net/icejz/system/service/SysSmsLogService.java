package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysSmsLogEntity;
import net.icejz.system.query.SysSmsLogQuery;
import net.icejz.system.vo.SysSmsLogVO;

import java.util.List;

/**
 * 短信日志
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysSmsLogService extends BaseService<SysSmsLogEntity> {

    PageResult<SysSmsLogVO> page(SysSmsLogQuery query);

    void delete(List<Long> idList);
}