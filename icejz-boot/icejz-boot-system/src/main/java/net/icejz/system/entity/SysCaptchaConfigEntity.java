package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

/**
 * 验证码配置（独立表，支持按租户扩展）
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_captcha_config")
public class SysCaptchaConfigEntity extends BaseEntity {

    /** 租户ID */
    private Long tenantId;

    /** 账号登录验证码开关 0关 1开 */
    private Integer enabled;

    /** PC 管理端账号登录验证码类型 */
    private String pcType;

    /** 移动端登录验证码类型 */
    private String appType;

    /** 短信发送前图形验证码类型 */
    private String smsType;

    /** Turnstile Site Key */
    private String turnstileSiteKey;

    /** Turnstile Secret Key */
    private String turnstileSecretKey;

    /** PoW 前导 0 个数 */
    private Integer powDifficulty;

    /** 备注 */
    private String remark;
}
