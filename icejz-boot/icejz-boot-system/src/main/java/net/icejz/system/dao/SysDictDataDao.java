package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysDictDataEntity;
import net.icejz.system.vo.SysDictVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 字典数据
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Mapper
public interface SysDictDataDao extends BaseDao<SysDictDataEntity> {

    @Select("${sql}")
    List<SysDictVO.DictData> getListForSql(@Param("sql") String sql);
}
