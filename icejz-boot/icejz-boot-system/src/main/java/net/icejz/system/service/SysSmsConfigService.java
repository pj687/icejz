package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.sms.config.SmsConfig;
import net.icejz.system.entity.SysSmsConfigEntity;
import net.icejz.system.query.SysSmsConfigQuery;
import net.icejz.system.vo.SysSmsConfigVO;

import java.util.List;

/**
 * 短信配置
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysSmsConfigService extends BaseService<SysSmsConfigEntity> {

    PageResult<SysSmsConfigVO> page(SysSmsConfigQuery query);

    List<SysSmsConfigVO> list(Integer platform);

    /**
     * 启用的短信平台列表
     */
    List<SmsConfig> listByEnable();

    void save(SysSmsConfigVO vo);

    void update(SysSmsConfigVO vo);

    void delete(List<Long> idList);

}