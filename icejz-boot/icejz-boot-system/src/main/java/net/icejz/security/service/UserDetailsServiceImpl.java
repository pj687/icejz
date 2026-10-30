package net.icejz.security.service;

import cn.hutool.core.bean.BeanUtil;
import lombok.AllArgsConstructor;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.service.SysUserDetailsService;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * 账号登录 UserDetailsService
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {
    private final SysUserDetailsService sysUserDetailsService;
    private final SysUserDao sysUserDao;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        SysUserEntity userEntity = sysUserDao.getByUsername(username);
        if (userEntity == null) {
            throw new UsernameNotFoundException("用户名或密码错误");
        }

        return sysUserDetailsService.getUserDetails(BeanUtil.copyProperties(userEntity, UserDetail.class));
    }

}
