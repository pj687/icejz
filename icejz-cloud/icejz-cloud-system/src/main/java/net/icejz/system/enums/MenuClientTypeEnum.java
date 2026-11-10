package net.icejz.system.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 菜单客户端类型
 */
@Getter
@AllArgsConstructor
public enum MenuClientTypeEnum {
    /**
     * PC 管理端
     */
    PC(0),
    /**
     * APP（UniApp App / Android / Flutter 工作台）
     */
    APP(1),
    /**
     * 微信小程序
     */
    MP(2);

    private final int value;
}
