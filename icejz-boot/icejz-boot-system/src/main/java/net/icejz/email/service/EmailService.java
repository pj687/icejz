package net.icejz.email.service;

import cn.hutool.core.util.ArrayUtil;
import cn.hutool.core.util.StrUtil;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.icejz.email.config.EmailConfig;
import net.icejz.email.param.EmailAliyunBatchSendParam;
import net.icejz.email.param.EmailAliyunSendParam;
import net.icejz.email.param.EmailLocalSendParam;
import net.icejz.email.util.EmailAliyunUtil;
import net.icejz.email.util.EmailLocalUtil;
import net.icejz.framework.common.constant.Constant;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.common.utils.ExceptionUtils;
import net.icejz.system.cache.EmailConfigCache;
import net.icejz.system.entity.SysMailLogEntity;
import net.icejz.system.service.SysMailConfigService;
import net.icejz.system.service.SysMailLogService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import java.io.File;
import java.util.List;

/**
 * 邮件服务
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Slf4j
@Service
@AllArgsConstructor
public class EmailService {
    private final SysMailConfigService sysMailConfigService;
    private final EmailConfigCache emailConfigCache;
    private final SysMailLogService sysMailLogService;

    /**
     * 本地 发送邮件
     *
     * @param param 发送邮件参数
     * @return message-id
     */
    public boolean sendLocal(EmailLocalSendParam param) {
        EmailConfig config = roundEmailConfig(param.getGroupName());
        return sendLocal(param, config);
    }

    /**
     * 本地 发送邮件
     *
     * @param param 发送邮件参数
     * @return message-id
     */
    public boolean sendLocal(EmailLocalSendParam param, EmailConfig config) {
        try {
            new EmailLocalUtil(config).sendEmail(param.getTos(), param.getSubject(), param.getContent(), param.isHtml(), ArrayUtil.toArray(param.getFiles(), File.class));
            saveLog(config.getId(), config.getPlatform(), config.getMailFrom(), param.getTos(), param.getSubject(), param.getContent(), null);

            return true;
        } catch (Exception e) {
            log.error("本地发送邮件失败", e);
            saveLog(config.getId(), config.getPlatform(), config.getMailFrom(), param.getTos(), param.getSubject(), param.getContent(), e);
            return false;
        }
    }


    /**
     * 阿里云 发送邮件
     *
     * @param param 发送邮件参数
     * @return env-id
     */
    public boolean sendAliyun(EmailAliyunSendParam param) {
        EmailConfig config = roundEmailConfig(param.getGroupName());

        return sendAliyun(param, config);
    }

    /**
     * 阿里云 发送邮件
     *
     * @param param 发送邮件参数
     * @return env-id
     */
    public boolean sendAliyun(EmailAliyunSendParam param, EmailConfig config) {
        try {
            new EmailAliyunUtil(config).sendEmail(param.getFrom(), param.getFormAlias(), param.getTos(), param.getSubject(), param.getContent(), param.isHtml());
            saveLog(config.getId(), config.getPlatform(), param.getFrom(), param.getTos(), param.getSubject(), param.getContent(), null);

            return true;
        } catch (Exception e) {
            log.error("阿里云发送邮件失败", e);
            saveLog(config.getId(), config.getPlatform(), param.getFrom(), param.getTos(), param.getSubject(), param.getContent(), e);
            return false;
        }
    }

    /**
     * 阿里云 批量发送邮件
     *
     * @param param 发送邮件参数
     * @return message-id
     */
    public boolean batchSendAliyun(EmailAliyunBatchSendParam param) {
        EmailConfig config = roundEmailConfig(param.getGroupName());

        return batchSendAliyun(param, config);
    }

    /**
     * 阿里云 批量发送邮件
     *
     * @param param 发送邮件参数
     * @return message-id
     */
    public boolean batchSendAliyun(EmailAliyunBatchSendParam param, EmailConfig config) {
        try {
            new EmailAliyunUtil(config).batchSendEmail(param.getFrom(), param.getReceiversName(), param.getTemplateName(), param.getTagName());
            saveLog(config.getId(), config.getPlatform(), param.getFrom(), param.getReceiversName(), null, param.getTemplateName(), null);

            return true;
        } catch (Exception e) {
            log.error("阿里云发送邮件失败", e);
            saveLog(config.getId(), config.getPlatform(), param.getFrom(), param.getReceiversName(), null, param.getTemplateName(), e);
            return false;
        }
    }

    /**
     * 保存邮件日志
     */
    public void saveLog(Long platformId, Integer platform, String mailFrom, String mailTos, String subject, String content, Exception e) {
        SysMailLogEntity logEntity = new SysMailLogEntity();
        logEntity.setPlatformId(platformId);
        logEntity.setPlatform(platform);
        logEntity.setMailFrom(mailFrom);
        logEntity.setMailTos(mailTos);
        logEntity.setSubject(subject);
        logEntity.setContent(content);

        if (e != null) {
            String error = StringUtils.substring(ExceptionUtils.getExceptionMessage(e), 0, 2000);
            logEntity.setStatus(Constant.FAIL);
            logEntity.setError(error);
        } else {
            logEntity.setStatus(Constant.SUCCESS);
        }

        sysMailLogService.save(logEntity);
    }

    /**
     * 通过轮询算法，获取邮件平台的配置
     *
     * @param groupName 分组名称
     * @return 邮件平台配置
     */
    private EmailConfig roundEmailConfig(String groupName) {
        List<EmailConfig> platformList = sysMailConfigService.listByEnable();

        // 是否有可用的邮件平台
        if (platformList.isEmpty()) {
            throw new ServerException("没有可用的邮件平台，请先添加");
        }

        // 没有分组的情况
        if (StrUtil.isBlank(groupName)) {
            // 采用轮询算法，发送邮件
            long round = emailConfigCache.getRoundValue();

            return platformList.get((int) round % platformList.size());
        }


        // 有分组的情况
        List<EmailConfig> newList = platformList.stream().filter(platform -> StrUtil.equals(platform.getGroupName(), groupName)).toList();
        if (newList.isEmpty()) {
            throw new ServerException("邮件分组不存在");
        }

        long round = emailConfigCache.getRoundCodeValue();

        // 指定邮件平台
        return newList.get((int) round % newList.size());
    }

}
