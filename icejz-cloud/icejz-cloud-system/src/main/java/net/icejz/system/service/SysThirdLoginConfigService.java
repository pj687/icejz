package net.icejz.system.service;

import me.zhyd.oauth.request.AuthRequest;
import net.icejz.framework.common.query.Query;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysThirdLoginConfigEntity;
import net.icejz.system.vo.SysThirdLoginConfigVO;

import java.util.List;

/**
 * 第三方登录配置
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysThirdLoginConfigService extends BaseService<SysThirdLoginConfigEntity> {

    PageResult<SysThirdLoginConfigVO> page(Query query);

    void save(SysThirdLoginConfigVO vo);

    void update(SysThirdLoginConfigVO vo);

    void delete(List<Long> idList);

    /**
     * 根据类型，获取授权请求
     *
     * @param openType 第三方登录类型
     */
    AuthRequest getAuthRequest(String openType);
}