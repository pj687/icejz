package net.icejz.system.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 字典数据来源
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Getter
@AllArgsConstructor
public enum DictSourceEnum {
    /**
     * 字典数据
     */
    DICT(0),
    /**
     * 动态SQL
     */
    SQL(1);

    private final int value;
}
