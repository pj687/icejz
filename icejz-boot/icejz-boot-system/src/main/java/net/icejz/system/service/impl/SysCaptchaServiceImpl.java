package net.icejz.system.service.impl;

import cn.hutool.core.lang.UUID;
import cn.hutool.core.util.StrUtil;
import cn.hutool.crypto.digest.DigestUtil;
import cn.hutool.http.HttpUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.icejz.framework.common.cache.RedisCache;
import net.icejz.framework.common.cache.RedisKeys;
import net.icejz.system.cache.SysParamsCache;
import net.icejz.system.captcha.CaptchaGenerator;
import net.icejz.system.dao.SysParamsDao;
import net.icejz.system.entity.SysParamsEntity;
import net.icejz.system.enums.CaptchaChannelEnum;
import net.icejz.system.enums.CaptchaTypeEnum;
import net.icejz.system.enums.SysParamsEnum;
import net.icejz.system.service.SysCaptchaService;
import net.icejz.system.vo.SysCaptchaVO;
import org.springframework.stereotype.Service;


/**
 * 验证码（字符 / 行为 / PoW / Turnstile），支持分端类型
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Slf4j
@Service
@AllArgsConstructor
public class SysCaptchaServiceImpl implements SysCaptchaService {
    private static final int CAPTCHA_TTL = 300;
    private static final int SLIDER_OFFSET = 8;
    private static final int WORD_OFFSET = 28;
    /** 图案点选半径更严，避免点到邻近错误图案仍判定通过 */
    private static final int PATTERN_OFFSET = 22;
    private static final String TYPE_SEP = "::";

    private final RedisCache redisCache;
    private final SysParamsDao sysParamsDao;
    private final SysParamsCache sysParamsCache;

    @Override
    public SysCaptchaVO generate(String channel) {
        CaptchaChannelEnum ch = CaptchaChannelEnum.of(channel);
        CaptchaTypeEnum type = resolveType(ch);
        SysCaptchaVO vo = new SysCaptchaVO();
        vo.setType(type.getCode());
        vo.setMode(type.getMode());
        vo.setTip(type.getTip());
        vo.setEnabled(isCaptchaEnabled());

        if (type == CaptchaTypeEnum.TURNSTILE) {
            String siteKey = safeParam(SysParamsEnum.TURNSTILE_SITE_KEY.name(), "");
            vo.setKey("turnstile");
            vo.setSiteKey(siteKey);
            vo.setTip(StrUtil.isBlank(siteKey) ? "未配置 Turnstile 站点密钥，请改用其他验证码类型" : type.getTip());
            return vo;
        }

        if (type == CaptchaTypeEnum.POW) {
            int difficulty = safeInt(SysParamsEnum.CAPTCHA_POW_DIFFICULTY.name(), 3);
            difficulty = Math.max(2, Math.min(difficulty, 5));
            String challenge = UUID.randomUUID().toString().replace("-", "");
            String key = UUID.randomUUID().toString();
            redisCache.set(RedisKeys.getCaptchaKey(key), wrap(type, challenge + "|" + difficulty), CAPTCHA_TTL);
            vo.setKey(key);
            vo.setChallenge(challenge);
            vo.setDifficulty(difficulty);
            vo.setTip("安全校验中，请稍候…");
            return vo;
        }

        CaptchaGenerator.CaptchaImage generated = CaptchaGenerator.create(type);
        String key = UUID.randomUUID().toString();
        redisCache.set(RedisKeys.getCaptchaKey(key), wrap(type, generated.text()), CAPTCHA_TTL);

        vo.setKey(key);
        vo.setImage(generated.imageBase64());
        vo.setTip(generated.tip());
        vo.setJigsawImage(generated.jigsawImage());
        vo.setJigsawY(generated.jigsawY());
        vo.setWords(generated.words());
        if (type == CaptchaTypeEnum.BLOCK_PUZZLE) {
            vo.setPuzzleWidth(CaptchaGenerator.PUZZLE_W);
            vo.setPuzzleHeight(CaptchaGenerator.PUZZLE_H);
            vo.setJigsawWidth(CaptchaGenerator.jigsawCanvasSize());
            vo.setPieceSize(CaptchaGenerator.PIECE);
        }
        return vo;
    }

    @Override
    public boolean validate(String key, String code) {
        if (!isCaptchaEnabled()) {
            return true;
        }
        return validateRequired(key, code);
    }

    @Override
    public boolean validateRequired(String key, String code) {
        if (StrUtil.isBlank(key) || StrUtil.isBlank(code)) {
            return false;
        }

        if ("turnstile".equalsIgnoreCase(key)) {
            return verifyTurnstile(code);
        }

        String cached = getCache(key);
        if (StrUtil.isBlank(cached)) {
            return false;
        }

        return matchCaptcha(cached, code);
    }

    @Override
    public boolean check(String key, String code) {
        if (StrUtil.isBlank(key) || StrUtil.isBlank(code)) {
            return false;
        }
        if ("turnstile".equalsIgnoreCase(key)) {
            return false;
        }
        String cached = peekCache(key);
        if (StrUtil.isBlank(cached)) {
            return false;
        }
        return matchCaptcha(cached, code);
    }

    private boolean matchCaptcha(String cached, String code) {
        CaptchaTypeEnum type = unwrapType(cached);
        String payload = unwrapPayload(cached);

        if (type == CaptchaTypeEnum.POW) {
            return verifyPow(payload, code);
        }
        if (type == CaptchaTypeEnum.BLOCK_PUZZLE) {
            return verifySlider(payload, code);
        }
        if (type == CaptchaTypeEnum.CLICK_WORD) {
            return verifyClickPoints(payload, code, WORD_OFFSET);
        }
        if (type == CaptchaTypeEnum.PATTERN) {
            return verifyClickPoints(payload, code, PATTERN_OFFSET);
        }
        return code.equalsIgnoreCase(payload);
    }

    @Override
    public boolean isCaptchaEnabled() {
        return Boolean.parseBoolean(safeParam(SysParamsEnum.LOGIN_CAPTCHA.name(), "false"));
    }




    private String wrap(CaptchaTypeEnum type, String payload) {
        return type.getCode() + TYPE_SEP + StrUtil.nullToDefault(payload, "");
    }

    private CaptchaTypeEnum unwrapType(String cached) {
        int idx = cached.indexOf(TYPE_SEP);
        if (idx > 0) {
            return CaptchaTypeEnum.of(cached.substring(0, idx));
        }
        return CaptchaTypeEnum.of(safeParam(SysParamsEnum.LOGIN_CAPTCHA_TYPE.name(), "spec"));
    }

    private String unwrapPayload(String cached) {
        int idx = cached.indexOf(TYPE_SEP);
        if (idx >= 0) {
            return cached.substring(idx + TYPE_SEP.length());
        }
        return cached;
    }

    private CaptchaTypeEnum resolveType(CaptchaChannelEnum channel) {
        String typed = safeParam(channel.getTypeParam().name(), "");
        if (StrUtil.isNotBlank(typed)) {
            return CaptchaTypeEnum.of(typed);
        }
        return CaptchaTypeEnum.of(safeParam(SysParamsEnum.LOGIN_CAPTCHA_TYPE.name(), "spec"));
    }

    private boolean verifySlider(String expectX, String actualX) {
        try {
            int expect = Integer.parseInt(expectX.trim());
            int actual = Integer.parseInt(actualX.trim());
            return Math.abs(expect - actual) <= SLIDER_OFFSET;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean verifyClickPoints(String expect, String actual, int offset) {
        String[] eParts = expect.split("\\|");
        String[] aParts = actual.split("\\|");
        if (eParts.length != aParts.length || eParts.length == 0) {
            return false;
        }
        try {
            for (int i = 0; i < eParts.length; i++) {
                String[] e = eParts[i].split(",");
                String[] a = aParts[i].split(",");
                int ex = Integer.parseInt(e[0].trim());
                int ey = Integer.parseInt(e[1].trim());
                int ax = Integer.parseInt(a[0].trim());
                int ay = Integer.parseInt(a[1].trim());
                if (Math.hypot(ex - ax, ey - ay) > offset) {
                    return false;
                }
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean verifyPow(String cached, String nonce) {
        String[] parts = cached.split("\\|");
        if (parts.length != 2) {
            return false;
        }
        String challenge = parts[0];
        int difficulty;
        try {
            difficulty = Integer.parseInt(parts[1]);
        } catch (Exception e) {
            return false;
        }
        String hash = DigestUtil.sha256Hex(challenge + nonce);
        return hash.startsWith("0".repeat(difficulty));
    }

    private boolean verifyTurnstile(String token) {
        String secret = safeParam(SysParamsEnum.TURNSTILE_SECRET_KEY.name(), "");
        if (StrUtil.isBlank(secret)) {
            log.warn("Turnstile secret 未配置");
            return false;
        }
        try {
            String body = HttpUtil.post(
                    "https://challenges.cloudflare.com/turnstile/v0/siteverify",
                    "secret=" + secret + "&response=" + token
            );
            JSONObject json = JSONUtil.parseObj(body);
            return Boolean.TRUE.equals(json.getBool("success"));
        } catch (Exception e) {
            log.error("Turnstile 校验失败", e);
            return false;
        }
    }


    private String safeParam(String key, String defaultValue) {
        try {
            String value = sysParamsCache.get(key);
            if (StrUtil.isNotBlank(value)) {
                return value;
            }
            SysParamsEntity entity = sysParamsDao.get(key);
            if (entity == null || StrUtil.isBlank(entity.getParamValue())) {
                return defaultValue;
            }
            sysParamsCache.save(entity.getParamKey(), entity.getParamValue());
            return entity.getParamValue();
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private int safeInt(String key, int defaultValue) {
        try {
            return Integer.parseInt(safeParam(key, String.valueOf(defaultValue)));
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String getCache(String key) {
        key = RedisKeys.getCaptchaKey(key);
        String captcha = (String) redisCache.get(key);
        if (captcha != null) {
            redisCache.delete(key);
        }
        return captcha;
    }

    /** 仅读取，不删除，供滑动拼图松手预校验 */
    private String peekCache(String key) {
        return (String) redisCache.get(RedisKeys.getCaptchaKey(key));
    }
}
