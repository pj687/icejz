package ${package}.${moduleName}.dao;

import ${package}.framework.mybatis.dao.BaseDao;
import ${package}.${moduleName}.entity.${ClassName}Entity;
import org.apache.ibatis.annotations.Mapper;

/**
 * ${tableComment}
 *
 * @author ${author} ${email!}
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Mapper
public interface ${ClassName}Dao extends BaseDao<${ClassName}Entity> {

}