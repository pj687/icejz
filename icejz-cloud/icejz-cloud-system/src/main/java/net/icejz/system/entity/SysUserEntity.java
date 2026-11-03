package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.FieldStrategy;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;
import net.icejz.system.enums.UserStatusEnum;

/**
 * 用户
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_user")
public class SysUserEntity extends BaseEntity {
    /**
     * 用户名
     */
    private String username;
    /**
     * 密码
     */
    private String password;
    /**
     * 姓名
     */
    private String realName;
    /**
     * 头像
     */
    private String avatar;
    /**
     * 性别   0：男   1：女   2：未知
     */
    private Integer gender;
    /**
     * 邮箱
     */
    private String email;
    /**
     * 手机号
     */
    private String mobile;
    /**
     * 机构ID
     */
    private Long orgId;
    /**
     * 超级管理员   0：否   1：是
     */
    private Integer superAdmin;
    /**
     * 状态  {@link UserStatusEnum}
     */
    private Integer status;
    /**
     * 多设备登录：null 跟随系统；0 单设备；1 多设备
     */
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private Integer multiDeviceLogin;
    /**
     * 个人多设备上限：null 跟随系统
     */
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private Integer multiDeviceMax;
    /**
     * 机构名称
     */
    @TableField(exist = false)
    private String orgName;
    /**
     * 租户ID
     */
    private Long tenantId;
}
