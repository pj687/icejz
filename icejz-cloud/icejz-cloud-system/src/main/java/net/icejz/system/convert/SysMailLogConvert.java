package net.icejz.system.convert;

import net.icejz.system.entity.SysMailLogEntity;
import net.icejz.system.vo.SysMailLogVO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;

/**
 * 邮件日志
 *
 * @author ice_jz
 */
@Mapper
public interface SysMailLogConvert {
    SysMailLogConvert INSTANCE = Mappers.getMapper(SysMailLogConvert.class);

    SysMailLogEntity convert(SysMailLogVO vo);

    SysMailLogVO convert(SysMailLogEntity entity);

    List<SysMailLogVO> convertList(List<SysMailLogEntity> list);

}