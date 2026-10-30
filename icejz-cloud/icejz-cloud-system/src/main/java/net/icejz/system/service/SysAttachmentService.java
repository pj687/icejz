package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysAttachmentEntity;
import net.icejz.system.query.SysAttachmentQuery;
import net.icejz.system.vo.SysAttachmentVO;

import java.util.List;

/**
 * 附件管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysAttachmentService extends BaseService<SysAttachmentEntity> {

    PageResult<SysAttachmentVO> page(SysAttachmentQuery query);

    void save(SysAttachmentVO vo);

    void update(SysAttachmentVO vo);

    void delete(List<Long> idList);
}