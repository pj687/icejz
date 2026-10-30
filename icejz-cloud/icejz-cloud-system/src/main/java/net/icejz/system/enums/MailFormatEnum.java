package net.icejz.system.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 邮件格式枚举
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Getter
@AllArgsConstructor
public enum MailFormatEnum {
    /**
     * 纯文本
     */
    TEXT,
    /**
     * HTML
     */
    HTML,
    /**
     * 模板
     */
    TEMPLATE;
}
