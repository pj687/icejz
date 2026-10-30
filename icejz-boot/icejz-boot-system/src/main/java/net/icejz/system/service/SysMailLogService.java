package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysMailLogEntity;
import net.icejz.system.query.SysMailLogQuery;
import net.icejz.system.vo.SysMailLogVO;

import java.util.List;

/**
 * 邮件日志
 *
 * @author ice_jz
 */
public interface SysMailLogService extends BaseService<SysMailLogEntity> {

    PageResult<SysMailLogVO> page(SysMailLogQuery query);

    void delete(List<Long> idList);
}