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
import net.icejz.system.captcha.CaptchaGenerator;
import net.icejz.system.enums.CaptchaChannelEnum;
import net.icejz.system.enums.CaptchaTypeEnum;
import net.icejz.system.service.SysCaptchaConfigService;
import net.icejz.system.service.SysCaptchaService;
import net.icejz.system.vo.SysCaptchaVO;
import org.springframework.stereotype.Service;


/**
 * 验证码（字符 / 行为 / PoW / Turnstile），配置来自 sys_captcha_config
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Slf4j
@Service
@AllArgsConstructor
public class SysCaptchaServiceImpl implements SysCaptchaService {
    private static final int CAPTCHA_TTL = 300;
    /** 滑动拼图水平容差（逻辑像素） */
    private static final int SLIDER_OFFSET = 8;
    /** 绳子中点对齐容差，略宽于拼图，降低触屏操作难度 */
    private static final int CURVE_OFFSET = 16;
    private static final int WORD_OFFSET = 28;
    /** 图案点选半径更严，避免点到邻近错误图案仍判定通过 */
    private static final int PATTERN_OFFSET = 22;
    private static final int ANGLE_OFFSET = CaptchaGenerator.ANGLE_TOLERANCE;
    private static final String TYPE_SEP = "::";

    private final RedisCache redisCache;
    private final SysCaptchaConfigService sysCaptchaConfigService;

    @Override
    public SysCaptchaVO generate(String channel) {
        CaptchaChannelEnum ch = CaptchaChannelEnum.of(channel);
        CaptchaTypeEnum type = sysCaptchaConfigService.resolveType(ch);
        SysCaptchaVO vo = new SysCaptchaVO();
        vo.setType(type.getCode());
        vo.setMode(type.getMode());
        vo.setTip(type.getTip());
        vo.setEnabled(isCaptchaEnabled());

        if (type == CaptchaTypeEnum.TURNSTILE) {
            String siteKey = sysCaptchaConfigService.getTurnstileSiteKey();
            vo.setKey("turnstile");
            vo.setSiteKey(siteKey);
            vo.setTip(StrUtil.isBlank(siteKey) ? "未配置 Turnstile 站点密钥，请改用其他验证码类型" : type.getTip());
            return vo;
        }

        if (type == CaptchaTypeEnum.POW) {
            int difficulty = sysCaptchaConfigService.getPowDifficulty();
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
        if (type == CaptchaTypeEnum.BLOCK_PUZZLE || type == CaptchaTypeEnum.CURVE) {
            vo.setPuzzleWidth(CaptchaGenerator.PUZZLE_W);
            vo.setPuzzleHeight(CaptchaGenerator.PUZZLE_H);
            if (type == CaptchaTypeEnum.CURVE) {
                vo.setJigsawWidth(CaptchaGenerator.CURVE_ROPE_W);
                vo.setPieceSize(CaptchaGenerator.CURVE_ROPE_W);
            } else {
                vo.setJigsawWidth(CaptchaGenerator.jigsawCanvasSize());
                vo.setPieceSize(CaptchaGenerator.PIECE);
            }
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
            return verifySlider(payload, code, SLIDER_OFFSET);
        }
        if (type == CaptchaTypeEnum.CURVE) {
            return verifySlider(payload, code, CURVE_OFFSET);
        }
        if (type == CaptchaTypeEnum.CLICK_WORD) {
            return verifyClickPoints(payload, code, WORD_OFFSET);
        }
        if (type == CaptchaTypeEnum.PATTERN) {
            return verifyClickPoints(payload, code, PATTERN_OFFSET);
        }
        if (type == CaptchaTypeEnum.ROTATE || type == CaptchaTypeEnum.ANGLE) {
            return verifyAngle(payload, code);
        }
        return code.equalsIgnoreCase(payload);
    }

    /** 用户旋转角 + 服务端偏转角 ≈ 360°（或 0°） */
    private boolean verifyAngle(String expectAngle, String actualAngle) {
        try {
            int expect = Integer.parseInt(expectAngle.trim());
            int actual = Integer.parseInt(actualAngle.trim());
            int sum = Math.floorMod(expect + actual, 360);
            return sum <= ANGLE_OFFSET || sum >= 360 - ANGLE_OFFSET;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public boolean isCaptchaEnabled() {
        return sysCaptchaConfigService.isEnabled();
    }

    private String wrap(CaptchaTypeEnum type, String payload) {
        return type.getCode() + TYPE_SEP + StrUtil.nullToDefault(payload, "");
    }

    private CaptchaTypeEnum unwrapType(String cached) {
        int idx = cached.indexOf(TYPE_SEP);
        if (idx > 0) {
            return CaptchaTypeEnum.of(cached.substring(0, idx));
        }
        return CaptchaTypeEnum.SPEC;
    }

    private String unwrapPayload(String cached) {
        int idx = cached.indexOf(TYPE_SEP);
        if (idx >= 0) {
            return cached.substring(idx + TYPE_SEP.length());
        }
        return cached;
    }

    private boolean verifySlider(String expectX, String actualX, int offset) {
        try {
            int expect = Integer.parseInt(expectX.trim());
            int actual = Integer.parseInt(actualX.trim());
            return Math.abs(expect - actual) <= offset;
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
        String secret = sysCaptchaConfigService.getTurnstileSecretKey();
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
