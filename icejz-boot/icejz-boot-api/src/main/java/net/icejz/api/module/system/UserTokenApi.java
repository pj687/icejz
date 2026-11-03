package net.icejz.api.module.system;

/**
 * 用户令牌 API（跨模块失效会话）
 */
public interface UserTokenApi {

    /**
     * 按 accessToken 失效 DB 会话，并删除 Redis
     *
     * @param accessToken 访问令牌
     */
    void expireByAccessToken(String accessToken);
}
