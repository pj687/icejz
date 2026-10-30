package net.icejz.framework.mybatis.interceptor;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * 数据范围
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@AllArgsConstructor
public class DataScope {
    private String sqlFilter;

}