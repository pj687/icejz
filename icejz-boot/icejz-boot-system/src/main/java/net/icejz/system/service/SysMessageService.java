package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysMessageEntity;
import net.icejz.system.query.SysMessageMyQuery;
import net.icejz.system.query.SysMessageQuery;
import net.icejz.system.vo.SysMessageMyVO;
import net.icejz.system.vo.SysMessageVO;

import java.util.List;

/**
 * 站内消息
 */
public interface SysMessageService extends BaseService<SysMessageEntity> {

    PageResult<SysMessageVO> page(SysMessageQuery query);

    SysMessageVO getInfo(Long id);

    void send(SysMessageVO vo);

    void delete(List<Long> idList);

    PageResult<SysMessageMyVO> myPage(SysMessageMyQuery query);

    SysMessageMyVO myInfo(Long id);

    Long unreadCount();

    void read(Long id);

    void readAll();

    List<SysMessageMyVO> latest(int limit);
}
