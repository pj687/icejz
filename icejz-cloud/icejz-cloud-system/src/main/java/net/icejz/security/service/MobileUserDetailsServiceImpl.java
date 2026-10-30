package net.icejz.security.service;

import lombok.AllArgsConstructor;
import net.icejz.framework.security.mobile.MobileUserDetailsService;
import net.icejz.system.convert.SysUserConvert;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.service.SysUserDetailsService;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * 手机验证码登录 MobileUserDetailsService
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class MobileUserDetailsServiceImpl implements MobileUserDetailsService {
    private final SysUserDetailsService sysUserDetailsService;
    private final SysUserDao sysUserDao;

    @Override
    public UserDetails loadUserByMobile(String mobile) throws UsernameNotFoundException {
        SysUserEntity userEntity = sysUserDao.getByMobile(mobile);
        if (userEntity == null) {
            throw new UsernameNotFoundException("手机号或验证码错误");
        }

        return sysUserDetailsService.getUserDetails(SysUserConvert.INSTANCE.convertDetail(userEntity));
    }

}
