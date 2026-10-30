package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import jakarta.servlet.http.HttpServletRequest;
import lombok.AllArgsConstructor;
import lombok.SneakyThrows;
import net.icejz.framework.common.utils.ExcelUtils;
import net.icejz.framework.common.utils.HttpContextUtils;
import net.icejz.framework.common.utils.IpUtils;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.system.dao.SysLogLoginDao;
import net.icejz.system.entity.SysLogLoginEntity;
import net.icejz.system.query.SysLogLoginQuery;
import net.icejz.system.service.SysLogLoginService;
import net.icejz.system.vo.SysLogLoginVO;
import net.icejz.framework.common.trans.TransService;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 登录日志
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class SysLogLoginServiceImpl extends BaseServiceImpl<SysLogLoginDao, SysLogLoginEntity> implements SysLogLoginService {
    private final TransService transService;

    @Override
    public PageResult<SysLogLoginVO> page(SysLogLoginQuery query) {
        IPage<SysLogLoginEntity> page = baseMapper.selectPage(getPage(query), getWrapper(query));

        return new PageResult<>(BeanUtil.copyToList(page.getRecords(), SysLogLoginVO.class), page.getTotal());
    }

    private LambdaQueryWrapper<SysLogLoginEntity> getWrapper(SysLogLoginQuery query) {
        LambdaQueryWrapper<SysLogLoginEntity> wrapper = Wrappers.lambdaQuery();
        wrapper.like(StrUtil.isNotBlank(query.getUsername()), SysLogLoginEntity::getUsername, query.getUsername());
        wrapper.like(StrUtil.isNotBlank(query.getAddress()), SysLogLoginEntity::getAddress, query.getAddress());
        wrapper.like(query.getStatus() != null, SysLogLoginEntity::getStatus, query.getStatus());
        wrapper.orderByDesc(SysLogLoginEntity::getId);

        return wrapper;
    }

    @Override
    public void save(String username, Integer status, Integer operation) {
        HttpServletRequest request = HttpContextUtils.getHttpServletRequest();
        assert request != null;
        String userAgent = request.getHeader(HttpHeaders.USER_AGENT);
        String ip = IpUtils.getIpAddr(request);
        String address = IpUtils.getAddressByIP(ip);

        SysLogLoginEntity entity = new SysLogLoginEntity();
        entity.setUsername(username);
        entity.setStatus(status);
        entity.setOperation(operation);
        entity.setIp(ip);
        entity.setAddress(address);
        entity.setUserAgent(userAgent);

        baseMapper.insert(entity);
    }

    @Override
    @SneakyThrows
    public void export() {
        List<SysLogLoginEntity> list = list();
        List<SysLogLoginVO> sysLogLoginVOS = BeanUtil.copyToList(list, SysLogLoginVO.class);
        transService.transBatch(sysLogLoginVOS);
        // 写到浏览器打开
        ExcelUtils.excelExport(SysLogLoginVO.class, "登录日志", null, sysLogLoginVOS);
    }

}