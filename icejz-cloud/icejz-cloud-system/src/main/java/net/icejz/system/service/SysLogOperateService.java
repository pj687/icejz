package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysLogOperateEntity;
import net.icejz.system.query.SysLogOperateQuery;
import net.icejz.system.vo.SysLogOperateVO;

/**
 * 操作日志
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysLogOperateService extends BaseService<SysLogOperateEntity> {

    PageResult<SysLogOperateVO> page(SysLogOperateQuery query);
}