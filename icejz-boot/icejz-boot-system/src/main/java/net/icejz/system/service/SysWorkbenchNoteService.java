package net.icejz.system.service;

import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysWorkbenchNoteEntity;
import net.icejz.system.vo.SysWorkbenchNoteVO;

import java.util.List;

/**
 * 工作台日历记事
 */
public interface SysWorkbenchNoteService extends BaseService<SysWorkbenchNoteEntity> {

    List<SysWorkbenchNoteVO> listMine(String yearMonth);

    SysWorkbenchNoteVO saveMine(SysWorkbenchNoteVO vo);

    void deleteMine(List<Long> idList);
}
