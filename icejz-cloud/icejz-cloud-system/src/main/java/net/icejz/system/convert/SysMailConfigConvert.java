package net.icejz.system.convert;

import net.icejz.email.config.EmailConfig;
import net.icejz.system.entity.SysMailConfigEntity;
import net.icejz.system.vo.SysMailConfigVO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;

/**
 * 邮件配置
 *
 * @author ice_jz
 */
@Mapper
public interface SysMailConfigConvert {
    SysMailConfigConvert INSTANCE = Mappers.getMapper(SysMailConfigConvert.class);

    SysMailConfigEntity convert(SysMailConfigVO vo);

    SysMailConfigVO convert(SysMailConfigEntity entity);

    List<SysMailConfigVO> convertList(List<SysMailConfigEntity> list);

    EmailConfig convert2(SysMailConfigEntity entity);

    List<EmailConfig> convertList2(List<SysMailConfigEntity> list);

}