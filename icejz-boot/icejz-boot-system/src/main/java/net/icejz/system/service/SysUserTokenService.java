package net.icejz.system.service;

import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysUserTokenEntity;
import net.icejz.system.vo.SysUserDeviceVO;
import net.icejz.system.vo.SysUserTokenVO;

import java.util.List;


/**
 * 用户Token
 *
 * @author ice_jz
 */
public interface SysUserTokenService extends BaseService<SysUserTokenEntity> {

    /**
     * 根据用户ID，生成用户Token
     *
     * @param userId 用户ID
     * @return 用户Token
     */
    SysUserTokenVO createToken(Long userId);

    /**
     * 根据refreshToken，生成新Token
     *
     * @param refreshToken refreshToken
     * @return 用户Token
     */
    SysUserTokenVO refreshToken(String refreshToken);

    /**
     * Token过期（该用户全部会话）
     *
     * @param userId 用户ID
     */
    void expireToken(Long userId);

    /**
     * 按 accessToken 失效对应会话（DB + Redis）
     *
     * @param accessToken accessToken
     */
    void expireByAccessToken(String accessToken);

    /**
     * 强制下线用户全部在线会话（DB + Redis）
     *
     * @param userId 用户ID
     */
    void forceLogoutByUserId(Long userId);

    /**
     * 当前用户在线设备列表
     *
     * @param userId           用户ID
     * @param currentAccessToken 当前请求的 accessToken（用于标记本机）
     */
    List<SysUserDeviceVO> listOnlineDevices(Long userId, String currentAccessToken);

    /**
     * 在线设备列表；若本机会话缺少 IP/UA 等元数据，则从请求补全并写回 Redis/DB
     */
    List<SysUserDeviceVO> listOnlineDevices(Long userId, String currentAccessToken, jakarta.servlet.http.HttpServletRequest request);

    /**
     * 根据角色ID，更新用户缓存权限
     *
     * @param roleId 角色ID
     */
    void updateCacheAuthByRoleId(Long roleId);

    /**
     * 根据用户ID，更新用户缓存权限
     *
     * @param userId 用户ID
     */
    void updateCacheAuthByUserId(Long userId);
}
