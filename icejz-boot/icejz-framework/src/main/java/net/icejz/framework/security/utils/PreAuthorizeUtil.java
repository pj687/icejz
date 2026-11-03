package net.icejz.framework.security.utils;

import cn.hutool.extra.spring.SpringUtil;
import org.springframework.context.ApplicationContext;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * SpringSecurity @PreAuthorize 注解 权限标识
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public class PreAuthorizeUtil {

    /**
     * 获取 @PreAuthorize 注解的权限标识列表
     *
     * @return 权限标识列表
     */
    public static List<String> getPreAuthorizeList() {
        List<String> authorities = new ArrayList<>();
        ApplicationContext context = SpringUtil.getApplicationContext();
        String[] beanNames = context.getBeanNamesForAnnotation(Controller.class);
        for (String beanName : beanNames) {
            Object bean = context.getBean(beanName);
            Method[] methods = bean.getClass().getDeclaredMethods();
            for (Method method : methods) {
                PreAuthorize preAuthorize = AnnotationUtils.findAnnotation(method, PreAuthorize.class);
                if (preAuthorize != null) {
                    String value = preAuthorize.value();
                    // 提取 hasAuthority('xxx') / hasAnyAuthority('a','b')
                    Pattern pattern = Pattern.compile("(?:hasAuthority|hasAnyAuthority)\\(([^)]*)\\)");
                    Matcher matcher = pattern.matcher(value);
                    while (matcher.find()) {
                        Matcher codeMatcher = Pattern.compile("'([^']*)'").matcher(matcher.group(1));
                        while (codeMatcher.find()) {
                            authorities.add(codeMatcher.group(1));
                        }
                    }
                }
            }
        }

        return authorities;
    }

}