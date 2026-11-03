package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.query.SysRoleUserQuery;
import net.icejz.system.query.SysUserQuery;
import net.icejz.system.vo.SysUserAvatarVO;
import net.icejz.system.vo.SysUserBaseVO;
import net.icejz.system.vo.SysUserLoginSecurityVO;
import net.icejz.system.vo.SysUserSignatureVO;
import net.icejz.system.vo.SysUserStatusVO;
import net.icejz.system.vo.SysUserVO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 用户管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysUserService extends BaseService<SysUserEntity> {

    PageResult<SysUserVO> page(SysUserQuery query);

    /**
     * 用户详情（含机构名、角色/岗位 ID）
     */
    SysUserVO getDetail(Long id);

    void save(SysUserVO vo);

    void update(SysUserVO vo);

    /**
     * 更新用户状态（封禁/解封）；封禁时强制下线全部会话
     */
    void updateStatus(SysUserStatusVO vo);

    /**
     * 若临时封禁已到期则自动解封，返回解封后的实体（可能为原实体）
     */
    SysUserEntity releaseIfBanExpired(SysUserEntity user);

    /**
     * 登录失败时的封禁温馨提示（含原因、解封时间）
     */
    String getLoginBanTip(SysUserEntity user);

    void updateLoginInfo(SysUserBaseVO vo);

    /**
     * 当前登录用户的多设备偏好（含系统默认与生效值）
     */
    SysUserLoginSecurityVO getMyLoginSecurity();

    /**
     * 保存当前登录用户的多设备偏好
     */
    void updateMyLoginSecurity(SysUserLoginSecurityVO vo);

    void updateAvatar(SysUserAvatarVO avatar);

    void updateSignature(SysUserSignatureVO signature);

    void delete(List<Long> idList);

    /**
     * 获取用户姓名列表
     *
     * @param idList 用户ID列表
     * @return 用户姓名列表
     */
    List<String> getRealNameList(List<Long> idList);

    /**
     * 根据机构ID，获取用户列表
     *
     * @param orgId 根据机构ID
     * @return 用户列表
     */
    List<SysUserVO> getOrgUserList(Long orgId);

    SysUserVO getByMobile(String mobile);

    /**
     * 修改密码
     *
     * @param id          用户ID
     * @param newPassword 新密码
     */
    void updatePassword(Long id, String newPassword);

    /**
     * 分配角色，用户列表
     */
    PageResult<SysUserVO> roleUserPage(SysRoleUserQuery query);

    /**
     * 批量导入用户
     *
     * @param file     excel文件
     * @param password 密码
     */
    void importByExcel(MultipartFile file, String password);

    /**
     * 导出用户信息表格
     */
    void export();
}
