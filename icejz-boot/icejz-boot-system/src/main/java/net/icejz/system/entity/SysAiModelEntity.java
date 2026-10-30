package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

import java.math.BigDecimal;

/**
 * AI 模型配置
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_ai_model")
public class SysAiModelEntity extends BaseEntity {
    /**
     * 显示名称
     */
    private String name;

    /**
     * 厂商：openai / deepseek / ollama / qwen / custom
     */
    private String provider;

    /**
     * 接入类型 0本地 1线上
     */
    private Integer apiType;

    /**
     * 接口地址，如 https://api.openai.com/v1 或 http://127.0.0.1:11434/v1
     */
    private String baseUrl;

    /**
     * API Key（本地可空）
     */
    private String apiKey;

    /**
     * 模型名
     */
    private String modelName;

    /**
     * 温度
     */
    private BigDecimal temperature;

    /**
     * 最大 token
     */
    private Integer maxTokens;

    /**
     * 系统提示词
     */
    private String systemPrompt;

    /**
     * 是否默认 0否 1是
     */
    private Integer isDefault;

    /**
     * 排序
     */
    private Integer sort;

    /**
     * 状态 0禁用 1启用
     */
    private Integer status;

    /**
     * 备注
     */
    private String remark;
}
