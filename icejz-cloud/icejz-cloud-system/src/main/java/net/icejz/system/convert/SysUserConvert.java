package net.icejz.system.convert;

import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.vo.SysUserBaseVO;
import net.icejz.system.vo.SysUserExcelVO;
import net.icejz.system.vo.SysUserVO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;


@Mapper
public interface SysUserConvert {
    SysUserConvert INSTANCE = Mappers.getMapper(SysUserConvert.class);

    SysUserVO convert(SysUserEntity entity);

    SysUserEntity convert(SysUserVO vo);

    SysUserEntity convert(SysUserBaseVO vo);

    SysUserVO convert(UserDetail userDetail);

    UserDetail convertDetail(SysUserEntity entity);

    List<SysUserVO> convertList(List<SysUserEntity> list);

    List<SysUserExcelVO> convert2List(List<SysUserEntity> list);

    List<SysUserEntity> convertListEntity(List<SysUserExcelVO> list);

}
