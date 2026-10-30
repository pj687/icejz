package net.icejz.framework.security.user;

import org.springframework.security.core.context.SecurityContextHolder;

/**
 * 用户
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public class SecurityUser {

    /**
     * 获取用户信息
     */
    public static UserDetail getUser() {
        UserDetail user;
        try {
            user = (UserDetail) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        } catch (Exception e) {
            return null;
        }

        return user;
    }

    /**
     * 获取用户ID
     */
    public static Long getUserId() {
        UserDetail user = getUser();
        if (user == null) {
            return null;
        }

        return user.getId();
    }

    /**
     * 获取机构ID
     */
    public static Long getOrgId() {
        UserDetail user = getUser();
        if (user == null) {
            return null;
        }

        return user.getOrgId();
    }

}