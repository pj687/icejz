package net.icejz.system.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * AI 接入类型
 */
@Getter
@AllArgsConstructor
public enum AiApiTypeEnum {
    /**
     * 本地（Ollama / 私有化 OpenAI 兼容）
     */
    LOCAL(0),
    /**
     * 线上云模型
     */
    ONLINE(1);

    private final int value;
}
