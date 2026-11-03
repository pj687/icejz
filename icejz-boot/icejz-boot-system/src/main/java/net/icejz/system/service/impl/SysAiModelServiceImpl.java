package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpResponse;
import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.constant.Constant;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.system.dao.SysAiModelDao;
import net.icejz.system.dao.SysParamsDao;
import net.icejz.system.entity.SysAiModelEntity;
import net.icejz.system.entity.SysParamsEntity;
import net.icejz.system.query.SysAiModelQuery;
import net.icejz.system.service.SysAiChatSessionService;
import net.icejz.system.service.SysAiModelService;
import net.icejz.system.vo.SysAiChatResultVO;
import net.icejz.system.vo.SysAiChatVO;
import net.icejz.system.vo.SysAiModelVO;
import net.icejz.system.vo.SysAiRobotVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@AllArgsConstructor
public class SysAiModelServiceImpl extends BaseServiceImpl<SysAiModelDao, SysAiModelEntity> implements SysAiModelService {
    private static final String ROBOT_NAME = "AI_ROBOT_NAME";
    private static final String ROBOT_WELCOME = "AI_ROBOT_WELCOME";
    private static final String ROBOT_ENABLED = "AI_ROBOT_ENABLED";

    private final SysParamsDao sysParamsDao;
    private final SysAiChatSessionService sysAiChatSessionService;

    @Override
    public PageResult<SysAiModelVO> page(SysAiModelQuery query) {
        IPage<SysAiModelEntity> page = baseMapper.selectPage(getPage(query), getWrapper(query));
        return new PageResult<>(BeanUtil.copyToList(page.getRecords(), SysAiModelVO.class), page.getTotal());
    }

    private LambdaQueryWrapper<SysAiModelEntity> getWrapper(SysAiModelQuery query) {
        LambdaQueryWrapper<SysAiModelEntity> wrapper = Wrappers.lambdaQuery();
        wrapper.like(StrUtil.isNotBlank(query.getName()), SysAiModelEntity::getName, query.getName());
        wrapper.eq(query.getApiType() != null, SysAiModelEntity::getApiType, query.getApiType());
        wrapper.eq(query.getStatus() != null, SysAiModelEntity::getStatus, query.getStatus());
        wrapper.orderByAsc(SysAiModelEntity::getSort).orderByDesc(SysAiModelEntity::getId);
        return wrapper;
    }

    @Override
    public List<SysAiModelVO> listAll() {
        List<SysAiModelEntity> list = baseMapper.selectList(Wrappers.lambdaQuery(SysAiModelEntity.class)
                .orderByAsc(SysAiModelEntity::getSort)
                .orderByDesc(SysAiModelEntity::getId));
        return BeanUtil.copyToList(list, SysAiModelVO.class);
    }

    @Override
    public List<SysAiModelVO> listEnabled() {
        List<SysAiModelEntity> list = baseMapper.selectList(Wrappers.lambdaQuery(SysAiModelEntity.class)
                .eq(SysAiModelEntity::getStatus, Constant.ENABLE)
                .orderByAsc(SysAiModelEntity::getSort)
                .orderByDesc(SysAiModelEntity::getId));
        return BeanUtil.copyToList(list, SysAiModelVO.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void save(SysAiModelVO vo) {
        SysAiModelEntity entity = BeanUtil.copyProperties(vo, SysAiModelEntity.class);
        fillDefaults(entity);
        baseMapper.insert(entity);
        if (Integer.valueOf(1).equals(entity.getIsDefault())) {
            clearOtherDefault(entity.getId());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void update(SysAiModelVO vo) {
        SysAiModelEntity entity = BeanUtil.copyProperties(vo, SysAiModelEntity.class);
        fillDefaults(entity);
        updateById(entity);
        if (Integer.valueOf(1).equals(entity.getIsDefault())) {
            clearOtherDefault(entity.getId());
        }
    }

    private void fillDefaults(SysAiModelEntity entity) {
        if (entity.getTemperature() == null) {
            entity.setTemperature(new BigDecimal("0.7"));
        }
        if (entity.getMaxTokens() == null) {
            entity.setMaxTokens(2048);
        }
        if (entity.getSort() == null) {
            entity.setSort(0);
        }
        if (entity.getIsDefault() == null) {
            entity.setIsDefault(0);
        }
        if (entity.getStatus() == null) {
            entity.setStatus(1);
        }
        if (StrUtil.isBlank(entity.getSystemPrompt())) {
            entity.setSystemPrompt(DEFAULT_SYSTEM_PROMPT);
        }
    }

    private void clearOtherDefault(Long keepId) {
        List<SysAiModelEntity> list = baseMapper.selectList(Wrappers.lambdaQuery(SysAiModelEntity.class)
                .eq(SysAiModelEntity::getIsDefault, 1)
                .ne(keepId != null, SysAiModelEntity::getId, keepId));
        for (SysAiModelEntity item : list) {
            item.setIsDefault(0);
            updateById(item);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(List<Long> idList) {
        removeByIds(idList);
    }

    @Override
    public SysAiRobotVO getRobotInfo() {
        SysAiRobotVO vo = new SysAiRobotVO();
        vo.setName(StrUtil.blankToDefault(getParam(ROBOT_NAME), "小冰"));
        vo.setWelcome(StrUtil.blankToDefault(getParam(ROBOT_WELCOME), "你好，我是 ICEJZ 小冰，有什么可以帮你的？"));
        String enabled = getParam(ROBOT_ENABLED);
        vo.setEnabled(StrUtil.isBlank(enabled) || "true".equalsIgnoreCase(enabled) || "1".equals(enabled) ? 1 : 0);

        SysAiModelEntity def = baseMapper.selectOne(Wrappers.lambdaQuery(SysAiModelEntity.class)
                .eq(SysAiModelEntity::getStatus, Constant.ENABLE)
                .eq(SysAiModelEntity::getIsDefault, 1)
                .last("limit 1"));
        if (def == null) {
            def = baseMapper.selectOne(Wrappers.lambdaQuery(SysAiModelEntity.class)
                    .eq(SysAiModelEntity::getStatus, Constant.ENABLE)
                    .orderByAsc(SysAiModelEntity::getSort)
                    .last("limit 1"));
        }
        if (def != null) {
            vo.setDefaultModelId(def.getId());
        }
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveRobot(SysAiRobotVO vo) {
        upsertParam(ROBOT_NAME, "AI机器人名称", StrUtil.blankToDefault(vo.getName(), "小冰"), "ICEJZ IP 助手名称");
        upsertParam(ROBOT_WELCOME, "AI机器人欢迎语", StrUtil.blankToDefault(vo.getWelcome(), "你好，我是 ICEJZ 小冰，有什么可以帮你的？"), "助手欢迎语");
        upsertParam(ROBOT_ENABLED, "AI机器人开关", String.valueOf(vo.getEnabled() == null || vo.getEnabled() == 1), "是否启用助手入口");

        if (vo.getDefaultModelId() != null) {
            SysAiModelEntity entity = baseMapper.selectById(vo.getDefaultModelId());
            if (entity != null) {
                entity.setIsDefault(1);
                updateById(entity);
                clearOtherDefault(entity.getId());
            }
        }
    }

    private String getParam(String key) {
        SysParamsEntity entity = sysParamsDao.get(key);
        return entity == null ? null : entity.getParamValue();
    }

    private void upsertParam(String key, String name, String value, String remark) {
        SysParamsEntity entity = sysParamsDao.get(key);
        if (entity == null) {
            entity = new SysParamsEntity();
            entity.setParamKey(key);
            entity.setParamName(name);
            entity.setParamValue(value);
            entity.setParamType(1);
            entity.setRemark(remark);
            entity.setTenantId(10000L);
            sysParamsDao.insert(entity);
        } else {
            entity.setParamValue(value);
            entity.setParamName(name);
            entity.setRemark(remark);
            sysParamsDao.updateById(entity);
        }
    }

    @Override
    public SysAiChatResultVO chat(SysAiChatVO vo) {
        if (StrUtil.isBlank(vo.getMessage())) {
            throw new ServerException("请输入要询问小冰的内容");
        }

        SysAiRobotVO robot = getRobotInfo();
        if (robot.getEnabled() != null && robot.getEnabled() == 0) {
            throw new ServerException("小冰助手暂未启用，请联系管理员在系统配置中打开");
        }

        SysAiModelEntity model = resolveModel(vo.getModelId());
        if (model == null) {
            throw new ServerException("尚未配置可用 AI 模型，请由技术人员到「系统设置 · 系统配置 · AI助手 / 模型」接入");
        }

        String content = invokeOpenAiCompatible(model, vo);
        Long sessionId = sysAiChatSessionService.ensureMineSession(vo.getSessionId(), vo.getMessage());
        sysAiChatSessionService.appendTurn(sessionId, vo.getMessage(), content);

        SysAiChatResultVO result = new SysAiChatResultVO();
        result.setContent(content);
        result.setModelId(model.getId());
        result.setModelName(model.getName());
        result.setSessionId(sessionId);
        return result;
    }

    @Override
    public String testModel(Long id) {
        SysAiModelEntity model = baseMapper.selectById(id);
        if (model == null) {
            throw new ServerException("模型不存在");
        }
        SysAiChatVO vo = new SysAiChatVO();
        vo.setMessage("请用一句话介绍你自己");
        return invokeOpenAiCompatible(model, vo);
    }

    private SysAiModelEntity resolveModel(Long modelId) {
        if (modelId != null) {
            SysAiModelEntity entity = baseMapper.selectById(modelId);
            if (entity == null || !Integer.valueOf(Constant.ENABLE).equals(entity.getStatus())) {
                throw new ServerException("指定模型不可用");
            }
            return entity;
        }
        SysAiModelEntity def = baseMapper.selectOne(Wrappers.lambdaQuery(SysAiModelEntity.class)
                .eq(SysAiModelEntity::getStatus, Constant.ENABLE)
                .eq(SysAiModelEntity::getIsDefault, 1)
                .last("limit 1"));
        if (def != null) {
            return def;
        }
        return baseMapper.selectOne(Wrappers.lambdaQuery(SysAiModelEntity.class)
                .eq(SysAiModelEntity::getStatus, Constant.ENABLE)
                .orderByAsc(SysAiModelEntity::getSort)
                .last("limit 1"));
    }

    /** 小冰默认人设提示词 */
    private static final String DEFAULT_SYSTEM_PROMPT = """
            你是 ICEJZ 管理后台助手「小冰」。
            回答要求：
            1. 语气友好、简洁，优先给可执行建议，少空话；
            2. 熟悉平台模块：系统配置、用户权限、短信/邮件、AI 模型接入、业务管理等；
            3. 不确定时如实说明，并提示用户去「系统设置 · 系统配置 · AI助手」检查模型配置；
            4. 不要编造不存在的菜单、接口或密钥；不要输出与问题无关的长篇大论。
            """;

    private String invokeOpenAiCompatible(SysAiModelEntity model, SysAiChatVO vo) {
        if (StrUtil.isBlank(model.getBaseUrl()) || StrUtil.isBlank(model.getModelName())) {
            throw new ServerException("模型配置不完整：请填写 Base URL 和模型名称");
        }

        // 云端兼容接口（DeepSeek/OpenAI/通义等）必须带 Key；缺 Key 时上游常返回 Authentication Fails (governor)
        boolean needKey = model.getApiType() == null || model.getApiType() == 1;
        if (needKey && StrUtil.isBlank(model.getApiKey())) {
            throw new ServerException("模型鉴权失败：请到「系统配置 · AI助手」为当前模型填写有效的 API Key 后再试");
        }

        String url = normalizeChatUrl(model.getBaseUrl());
        JSONObject body = new JSONObject();
        body.set("model", model.getModelName());
        body.set("temperature", model.getTemperature() == null ? 0.7 : model.getTemperature());
        if (model.getMaxTokens() != null && model.getMaxTokens() > 0) {
            body.set("max_tokens", model.getMaxTokens());
        }
        body.set("stream", false);

        JSONArray messages = new JSONArray();
        JSONObject system = new JSONObject();
        system.set("role", "system");
        system.set("content", StrUtil.blankToDefault(model.getSystemPrompt(), DEFAULT_SYSTEM_PROMPT));
        messages.add(system);

        if (vo.getHistory() != null) {
            for (SysAiChatVO.ChatMessage item : vo.getHistory()) {
                if (item == null || StrUtil.isBlank(item.getContent()) || StrUtil.isBlank(item.getRole())) {
                    continue;
                }
                if (!"user".equals(item.getRole()) && !"assistant".equals(item.getRole())) {
                    continue;
                }
                JSONObject msg = new JSONObject();
                msg.set("role", item.getRole());
                msg.set("content", item.getContent());
                messages.add(msg);
            }
        }

        JSONObject user = new JSONObject();
        user.set("role", "user");
        user.set("content", vo.getMessage());
        messages.add(user);
        body.set("messages", messages);

        HttpRequest request = HttpRequest.post(url)
                .header("Content-Type", "application/json")
                .timeout(60000)
                .body(body.toString());
        if (StrUtil.isNotBlank(model.getApiKey())) {
            request.header("Authorization", "Bearer " + model.getApiKey().trim());
        }

        try (HttpResponse response = request.execute()) {
            String resp = response.body();
            if (!response.isOk()) {
                throw new ServerException(friendlyModelHttpError(response.getStatus(), resp));
            }
            JSONObject json = JSONUtil.parseObj(resp);
            JSONArray choices = json.getJSONArray("choices");
            if (choices == null || choices.isEmpty()) {
                String err = extractUpstreamError(json);
                throw new ServerException(StrUtil.blankToDefault(err, "模型未返回有效内容，请稍后重试或更换模型"));
            }
            JSONObject message = choices.getJSONObject(0).getJSONObject("message");
            if (message == null) {
                throw new ServerException("模型响应格式异常，请检查 Base URL 是否为 OpenAI 兼容接口");
            }
            String content = message.getStr("content");
            if (StrUtil.isBlank(content)) {
                throw new ServerException("模型返回空内容，可尝试调高 max_tokens 或换一个问题");
            }
            return content.trim();
        } catch (ServerException e) {
            throw e;
        } catch (Exception e) {
            throw new ServerException("连接模型失败，请检查 Base URL、网络与代理设置：" + e.getMessage());
        }
    }

    /**
     * 将上游原始错误（如 DeepSeek 的 Authentication Fails (governor)）转成可操作的中文提示。
     */
    private String friendlyModelHttpError(int status, String body) {
        String raw = StrUtil.blankToDefault(body, "").trim();
        String lower = raw.toLowerCase();

        if (status == 401 || lower.contains("authentication fails") || lower.contains("incorrect api key")
                || lower.contains("invalid api key") || lower.contains("unauthorized")) {
            return "模型鉴权失败（401）：API Key 无效、过期或未正确发送。"
                    + "请到「系统配置 · AI助手」核对 Key，确认 Base URL（如 DeepSeek 用 https://api.deepseek.com/v1），"
                    + "并确保账户余额充足后重试。";
        }
        if (status == 402 || lower.contains("insufficient") || lower.contains("balance") || lower.contains("quota")) {
            return "模型额度不足（402）：请登录模型服务商控制台充值或更换可用模型。";
        }
        if (status == 429 || lower.contains("rate limit") || lower.contains("too many")) {
            return "模型请求过于频繁（429）：请稍后再试，或降低并发。";
        }
        if (status == 400 || status == 422) {
            return "模型请求参数有误（" + status + "）：请检查模型名称、温度与 max_tokens。"
                    + (StrUtil.isBlank(raw) ? "" : " 详情：" + StrUtil.maxLength(raw, 160));
        }
        if (status >= 500) {
            return "模型服务暂时不可用（" + status + "）：请稍后重试。";
        }
        return "模型调用失败（" + status + "）"
                + (StrUtil.isBlank(raw) ? "" : "：" + StrUtil.maxLength(raw, 180));
    }

    private String extractUpstreamError(JSONObject json) {
        if (json == null) {
            return null;
        }
        Object err = json.get("error");
        if (err instanceof JSONObject errObj) {
            return StrUtil.blankToDefault(errObj.getStr("message"), errObj.getStr("code"));
        }
        if (err != null) {
            return String.valueOf(err);
        }
        return json.getStr("message");
    }

    private String normalizeChatUrl(String baseUrl) {
        String url = StrUtil.removeSuffix(baseUrl.trim(), "/");
        if (url.endsWith("/chat/completions")) {
            return url;
        }
        if (url.endsWith("/v1")) {
            return url + "/chat/completions";
        }
        return url + "/v1/chat/completions";
    }
}
