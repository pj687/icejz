package net.icejz.system.dao;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysMessageUserEntity;
import net.icejz.system.vo.SysMessageMyVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 站内消息接收
 */
@Mapper
public interface SysMessageUserDao extends BaseDao<SysMessageUserEntity> {

    IPage<SysMessageMyVO> selectMyPage(Page<SysMessageMyVO> page,
                                       @Param("receiverId") Long receiverId,
                                       @Param("readStatus") Integer readStatus,
                                       @Param("title") String title);

    Long countUnread(@Param("receiverId") Long receiverId);
}
