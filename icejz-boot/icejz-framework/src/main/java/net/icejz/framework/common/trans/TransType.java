package net.icejz.framework.common.trans;

/**
 * 翻译类型常量
 *
 * @author icejz
 */
public interface TransType {
    /**
     * 字典翻译
     */
    String DICTIONARY = "dictionary";

    /**
     * 简单翻译（通过实体类查找）
     */
    String SIMPLE = "simple";
}
