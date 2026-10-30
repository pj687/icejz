package net.icejz.framework.common.utils;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * 分页工具类
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@Schema(description = "分页数据")
public class PageResult<T> implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "总记录数")
    private int total;

    @Schema(description = "列表数据")
    private List<T> list;

    @Schema(description = "合计数据")
    private Map<String, Object> summary;

    /**
     * 分页
     * @param list   列表数据
     * @param total  总记录数
     */
    public PageResult(List<T> list, long total) {
        this.list = list;
        this.total = (int)total;
    }

    /**
     * 分页
     * @param list   列表数据
     * @param total  总记录数
     * @param summary 合计数据
     */
    public PageResult(List<T> list, long total, Map<String, Object> summary) {
        this.list = list;
        this.total = (int)total;
        this.summary = summary;
    }
}