package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

/**
 * 用户岗位关系
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@EqualsAndHashCode(callSuper=false)
@TableName("sys_user_post")
public class SysUserPostEntity extends BaseEntity {
	/**
	 * 用户ID
	 */
	private Long userId;
	/**
	* 岗位ID
	*/
	private Long postId;
}