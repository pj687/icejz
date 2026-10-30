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
            entity.setSystemPrompt("你是 ICEJZ 平台助手小冰，语气友好、简洁，擅长帮助用户理解平台功能、系统配置与研发协作问题。");
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

    private String invokeOpenAiCompatible(SysAiModelEntity model, SysAiChatVO vo) {
        if (StrUtil.isBlank(model.getBaseUrl()) || StrUtil.isBlank(model.getModelName())) {
            throw new ServerException("模型缺少 Base URL 或模型名称");
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
        system.set("content", StrUtil.blankToDefault(model.getSystemPrompt(),
                "你是 ICEJZ 平台助手小冰，语气友好、简洁。"));
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
            request.header("Authorization", "Bearer " + model.getApiKey());
        }

        try (HttpResponse response = request.execute()) {
            String resp = response.body();
            if (!response.isOk()) {
                throw new ServerException("模型调用失败(" + response.getStatus() + ")：" + StrUtil.maxLength(resp, 300));
            }
            JSONObject json = JSONUtil.parseObj(resp);
            JSONArray choices = json.getJSONArray("choices");
            if (choices == null || choices.isEmpty()) {
                // Ollama native fallback message format is rare with /v1; keep error clear
                String err = json.getStr("error");
                throw new ServerException(StrUtil.blankToDefault(err, "模型未返回有效内容"));
            }
            JSONObject message = choices.getJSONObject(0).getJSONObject("message");
            if (message == null) {
                throw new ServerException("模型响应格式异常");
            }
            String content = message.getStr("content");
            if (StrUtil.isBlank(content)) {
                throw new ServerException("模型返回空内容");
            }
            return content.trim();
        } catch (ServerException e) {
            throw e;
        } catch (Exception e) {
            throw new ServerException("连接模型失败：" + e.getMessage());
        }
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
