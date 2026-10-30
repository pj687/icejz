package net.icejz.system.convert;

import net.icejz.sms.config.SmsConfig;
import net.icejz.system.entity.SysSmsConfigEntity;
import net.icejz.system.vo.SysSmsConfigVO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;

/**
 * 短信配置
 *
 * @author ice_jz
 */
@Mapper
public interface SysSmsConfigConvert {
    SysSmsConfigConvert INSTANCE = Mappers.getMapper(SysSmsConfigConvert.class);

    SysSmsConfigEntity convert(SysSmsConfigVO vo);

    SysSmsConfigVO convert(SysSmsConfigEntity entity);

    List<SysSmsConfigVO> convertList(List<SysSmsConfigEntity> list);

    SmsConfig convert2(SysSmsConfigEntity entity);

    List<SmsConfig> convertList2(List<SysSmsConfigEntity> list);

}