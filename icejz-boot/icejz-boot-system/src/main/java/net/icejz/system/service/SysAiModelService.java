package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysAiModelEntity;
import net.icejz.system.query.SysAiModelQuery;
import net.icejz.system.vo.SysAiChatResultVO;
import net.icejz.system.vo.SysAiChatVO;
import net.icejz.system.vo.SysAiModelVO;
import net.icejz.system.vo.SysAiRobotVO;

import java.util.List;

public interface SysAiModelService extends BaseService<SysAiModelEntity> {

    PageResult<SysAiModelVO> page(SysAiModelQuery query);

    List<SysAiModelVO> listAll();

    List<SysAiModelVO> listEnabled();

    void save(SysAiModelVO vo);

    void update(SysAiModelVO vo);

    void delete(List<Long> idList);

    SysAiRobotVO getRobotInfo();

    void saveRobot(SysAiRobotVO vo);

    SysAiChatResultVO chat(SysAiChatVO vo);

    String testModel(Long id);
}
