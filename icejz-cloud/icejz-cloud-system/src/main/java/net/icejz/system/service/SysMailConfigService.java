package net.icejz.system.service;

import net.icejz.email.config.EmailConfig;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysMailConfigEntity;
import net.icejz.system.query.SysMailConfigQuery;
import net.icejz.system.vo.SysMailConfigVO;

import java.util.List;

/**
 * 邮件平台
 *
 * @author ice_jz
 */
public interface SysMailConfigService extends BaseService<SysMailConfigEntity> {

    PageResult<SysMailConfigVO> page(SysMailConfigQuery query);

    List<SysMailConfigVO> list(Integer platform);

    /**
     * 启用的邮件平台列表
     */
    List<EmailConfig> listByEnable();

    void save(SysMailConfigVO vo);

    void update(SysMailConfigVO vo);

    void delete(List<Long> idList);
}