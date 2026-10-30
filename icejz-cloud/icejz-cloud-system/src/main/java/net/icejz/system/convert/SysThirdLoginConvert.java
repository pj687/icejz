package net.icejz.system.convert;

import net.icejz.system.entity.SysThirdLoginEntity;
import net.icejz.system.vo.SysThirdLoginVO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;

/**
 * 第三方登录
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Mapper
public interface SysThirdLoginConvert {
    SysThirdLoginConvert INSTANCE = Mappers.getMapper(SysThirdLoginConvert.class);

    SysThirdLoginEntity convert(SysThirdLoginVO vo);

    SysThirdLoginVO convert(SysThirdLoginEntity entity);

    List<SysThirdLoginVO> convertList(List<SysThirdLoginEntity> list);

}