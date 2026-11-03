package net.icejz.security.service;

import cn.hutool.core.bean.BeanUtil;
import lombok.AllArgsConstructor;
import net.icejz.framework.security.third.ThirdUserDetailsService;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.service.SysThirdLoginService;
import net.icejz.system.service.SysUserDetailsService;
import net.icejz.system.service.SysUserService;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * 第三方登录，ThirdUserDetailsService
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class ThirdUserDetailsServiceImpl implements ThirdUserDetailsService {
    private final SysUserDetailsService sysUserDetailsService;
    private final SysThirdLoginService sysThirdLoginService;
    private final SysUserDao sysUserDao;
    private final SysUserService sysUserService;

    @Override
    public UserDetails loadUserByOpenTypeAndOpenId(String openType, String openId) throws UsernameNotFoundException {
        Long userId = sysThirdLoginService.getUserIdByOpenTypeAndOpenId(openType, openId);
        SysUserEntity userEntity = sysUserDao.getById(userId);
        if (userEntity == null) {
            throw new UsernameNotFoundException("绑定的系统用户，不存在");
        }
        userEntity = sysUserService.releaseIfBanExpired(userEntity);

        return sysUserDetailsService.getUserDetails(BeanUtil.copyProperties(userEntity, UserDetail.class));
    }
}
