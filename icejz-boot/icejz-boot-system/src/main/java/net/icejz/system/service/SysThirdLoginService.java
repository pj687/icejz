package net.icejz.system.service;

import me.zhyd.oauth.model.AuthUser;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysThirdLoginEntity;
import net.icejz.system.vo.SysThirdLoginVO;

import java.util.List;

/**
 * 第三方登录
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysThirdLoginService extends BaseService<SysThirdLoginEntity> {

    List<SysThirdLoginVO> listByUserId(Long userId);

    void unBind(Long userId, String openType);

    void bind(Long userId, String openType, AuthUser authUser);

    /**
     * 根据第三方登录类型和openId，查询用户Id
     *
     * @param openType 第三方登录类型
     * @param openId   第三方用户唯一标识
     * @return 用户Id
     */
    Long getUserIdByOpenTypeAndOpenId(String openType, String openId);

}