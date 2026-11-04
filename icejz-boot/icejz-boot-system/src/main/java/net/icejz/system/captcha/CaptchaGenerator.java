package net.icejz.system.captcha;

import cn.hutool.core.util.RandomUtil;
import com.wf.captcha.ChineseCaptcha;
import com.wf.captcha.SpecCaptcha;
import com.wf.captcha.base.Captcha;
import net.icejz.system.enums.CaptchaTypeEnum;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.geom.Ellipse2D;
import java.awt.geom.GeneralPath;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.List;
import java.util.Random;

/**
 * 多类型验证码生成
 */
public final class CaptchaGenerator {
    private static final int WIDTH = 200;
    private static final int HEIGHT = 56;
    /** 每轮展示数量；画布 310×155，4 个更易拉开间距 */
    private static final int PATTERN_SLOTS = 4;

    public static final int PUZZLE_W = 310;
    public static final int PUZZLE_H = 155;
    /** 拼图块主体边长（不含凸起） */
    public static final int PIECE = 42;

    public static int pieceKnob() {
        return Math.max(6, PIECE / 5);
    }

    public static int jigsawCanvasSize() {
        return PIECE + pieceKnob();
    }
    public static final int CLICK_W = 310;
    public static final int CLICK_H = 155;
    /** @deprecated 旧正弦曲线振幅，保留兼容 */
    @Deprecated
    public static final int CURVE_AMP = 28;
    /**
     * 滑动曲线：滑块行程占位（前端优先用 words 中的 travel）。
     * 两端钉在底图端点，滑块只改变中点，行程约 PUZZLE_W - CURVE_ROPE_W。
     */
    public static final int CURVE_ROPE_W = 100;
    /** @deprecated 旧路径描摹采样步长 */
    @Deprecated
    public static final int CURVE_SAMPLE_STEP = 4;
    public static final int ROTATE_SIZE = 200;
    public static final int ANGLE_TOLERANCE = 12;

    private CaptchaGenerator() {
    }

    public record CaptchaImage(
            String text,
            String imageBase64,
            String tip,
            String jigsawImage,
            Integer jigsawY,
            List<String> words
    ) {
        public CaptchaImage(String text, String imageBase64, String tip) {
            this(text, imageBase64, tip, null, null, null);
        }
    }

    public static CaptchaImage create(CaptchaTypeEnum type) {
        return switch (type) {
            case NUMBER -> fromEasy(newSpec(Captcha.TYPE_ONLY_NUMBER, 4), type);
            case CHINESE -> fromEasy(new ChineseCaptcha(WIDTH, HEIGHT, 4), type);
            case ARITHMETIC -> arithmetic();
            case PATTERN -> pattern();
            case BLOCK_PUZZLE -> blockPuzzle();
            case CLICK_WORD -> clickWord();
            case CURVE -> curveMatch();
            case ROTATE -> rotateCaptcha();
            case ANGLE -> angleCaptcha();
            default -> fromEasy(newSpec(Captcha.TYPE_DEFAULT, 5), CaptchaTypeEnum.SPEC);
        };
    }

    /** @deprecated 旧正弦轨迹；新版曲线以 words 路径点为准 */
    @Deprecated
    public static int curveY(int x) {
        double mid = (PUZZLE_H - PIECE) / 2.0;
        double span = Math.max(1, PUZZLE_W - PIECE);
        return (int) Math.round(mid + CURVE_AMP * Math.sin(2 * Math.PI * x / span));
    }

    private static SpecCaptcha newSpec(int charType, int len) {
        SpecCaptcha captcha = new SpecCaptcha(WIDTH, HEIGHT, len);
        captcha.setCharType(charType);
        return captcha;
    }

    private static CaptchaImage fromEasy(Captcha captcha, CaptchaTypeEnum type) {
        return new CaptchaImage(captcha.text(), captcha.toBase64(), type.getTip());
    }

    private static CaptchaImage arithmetic() {
        Random random = RandomUtil.getRandom();
        int a = random.nextInt(1, 10);
        int b = random.nextInt(1, 10);
        boolean plus = random.nextBoolean();
        if (!plus && a < b) {
            int t = a;
            a = b;
            b = t;
        }
        int answer = plus ? a + b : a - b;
        String formula = a + (plus ? "+" : "-") + b + "=?";

        BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        fillNoiseBackground(g, WIDTH, HEIGHT);
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setFont(new Font("SansSerif", Font.BOLD, 28));
        g.setColor(new Color(30, 60, 90));
        FontMetrics fm = g.getFontMetrics();
        int x = (WIDTH - fm.stringWidth(formula)) / 2;
        int y = (HEIGHT - fm.getHeight()) / 2 + fm.getAscent();
        g.drawString(formula, x, y);
        drawInterference(g, WIDTH, HEIGHT);
        g.dispose();
        return new CaptchaImage(String.valueOf(answer), toBase64(image), "请输入计算结果");
    }

    /** 点选图案图标库（每轮随机抽 PATTERN_SLOTS 个；每种图案唯一，提示只用心形/雨伞等名称） */
    private record PatternIcon(String name, Color color) {}

    private static final PatternIcon[] PATTERN_ICON_POOL = {
            new PatternIcon("爱心", new Color(244, 63, 94)),
            new PatternIcon("花朵", new Color(236, 72, 153)),
            new PatternIcon("小鱼", new Color(14, 165, 233)),
            new PatternIcon("叶子", new Color(22, 163, 74)),
            new PatternIcon("月亮", new Color(245, 158, 11)),
            new PatternIcon("单车", new Color(8, 145, 178)),
            new PatternIcon("小汽车", new Color(234, 88, 12)),
            new PatternIcon("大货车", new Color(37, 99, 235)),
            new PatternIcon("飞机", new Color(124, 58, 237)),
            new PatternIcon("帆船", new Color(13, 148, 136)),
            new PatternIcon("房子", new Color(180, 83, 9)),
            new PatternIcon("雨伞", new Color(219, 39, 119)),
            new PatternIcon("星星", new Color(234, 179, 8)),
            new PatternIcon("铃铛", new Color(249, 115, 22)),
            new PatternIcon("钥匙", new Color(161, 98, 7)),
            new PatternIcon("茶杯", new Color(59, 130, 246)),
            new PatternIcon("气球", new Color(239, 68, 68)),
            new PatternIcon("皇冠", new Color(217, 119, 6)),
            new PatternIcon("盾牌", new Color(37, 99, 235)),
            new PatternIcon("闪电", new Color(250, 204, 21)),
            new PatternIcon("蘑菇", new Color(220, 38, 38)),
            new PatternIcon("蝴蝶", new Color(168, 85, 247))
    };

    /** 图案点选：图标中心间距下限（须大于校验半径，并避免视觉过于贴近） */
    private static final int PATTERN_MIN_GAP = 100;

    /**
     * 点选图案（参考常见文字点选验证码交互）：
     * 风景底图上散落软图标，提示点击指定图案，答案为中心点坐标 x,y
     */
    private static CaptchaImage pattern() {
        List<PatternIcon> pool = new ArrayList<>(List.of(PATTERN_ICON_POOL));
        Collections.shuffle(pool);
        List<PatternIcon> picked = new ArrayList<>(pool.subList(0, Math.min(PATTERN_SLOTS, pool.size())));

        int answer = RandomUtil.randomInt(picked.size());
        PatternIcon target = picked.get(answer);
        // 每种图案每轮最多出现一次，提示只用名称，避免「玫红雨伞」与底色混淆
        String tip = "请点击：" + target.name();

        BufferedImage image = new BufferedImage(CLICK_W, CLICK_H, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        Random random = RandomUtil.getRandom();
        paintPuzzleBackground(g, random);

        List<int[]> slotPool = patternSlotCandidates(random);
        List<int[]> positions = new ArrayList<>();
        int[] answerCenter = new int[]{0, 0};
        for (int i = 0; i < picked.size(); i++) {
            PatternIcon icon = picked.get(i);
            int[] pos = takePatternSlot(slotPool, positions, random);
            int cx = pos[0];
            int cy = pos[1];
            positions.add(new int[]{cx, cy});
            if (i == answer) {
                answerCenter = new int[]{cx, cy};
            }
            double angle = Math.toRadians(random.nextInt(-16, 17));
            AffineTransform old = g.getTransform();
            g.rotate(angle, cx, cy);
            drawSoftIcon(g, icon.name(), icon.color(), cx, cy, 18);
            g.setTransform(old);
        }
        g.dispose();
        return new CaptchaImage(answerCenter[0] + "," + answerCenter[1], toBase64(image), tip);
    }

    /** 预生成较分散的候选点，再随机取用，保证间距 */
    private static List<int[]> patternSlotCandidates(Random random) {
        List<int[]> slots = new ArrayList<>();
        int[] xs = {52, 110, 168, 226, 258};
        int[] ys = {48, 78, 108};
        for (int x : xs) {
            for (int y : ys) {
                int jx = Math.min(CLICK_W - 44, Math.max(44, x + random.nextInt(-10, 11)));
                int jy = Math.min(CLICK_H - 34, Math.max(42, y + random.nextInt(-8, 9)));
                slots.add(new int[]{jx, jy});
            }
        }
        Collections.shuffle(slots, random);
        return slots;
    }

    private static int[] takePatternSlot(List<int[]> slotPool, List<int[]> used, Random random) {
        for (int i = 0; i < slotPool.size(); i++) {
            int[] cand = slotPool.get(i);
            if (!tooClose(used, cand[0], cand[1], PATTERN_MIN_GAP)) {
                slotPool.remove(i);
                return cand;
            }
        }
        // 兜底：随机多试几次
        for (int t = 0; t < 80; t++) {
            int cx = random.nextInt(48, CLICK_W - 48);
            int cy = random.nextInt(46, CLICK_H - 36);
            if (!tooClose(used, cx, cy, PATTERN_MIN_GAP)) {
                return new int[]{cx, cy};
            }
        }
        // 仍失败则尽量远离已有点
        int bestX = CLICK_W / 2;
        int bestY = CLICK_H / 2;
        double bestScore = -1;
        for (int t = 0; t < 40; t++) {
            int cx = random.nextInt(48, CLICK_W - 48);
            int cy = random.nextInt(46, CLICK_H - 36);
            double min = Double.MAX_VALUE;
            for (int[] p : used) {
                min = Math.min(min, Math.hypot(p[0] - cx, p[1] - cy));
            }
            if (min > bestScore) {
                bestScore = min;
                bestX = cx;
                bestY = cy;
            }
        }
        return new int[]{bestX, bestY};
    }

    /**
     * 滑动拼图（参考 AJ-Captcha blockPuzzle）：
     * - 底图挖缺口；滑块为透明 PNG 拼图块
     * - 答案为缺口左上角 X（原图像素），前端回传滑块 left
     */
    private static CaptchaImage blockPuzzle() {
        Random random = RandomUtil.getRandom();
        BufferedImage bg = new BufferedImage(PUZZLE_W, PUZZLE_H, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = bg.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        paintPuzzleBackground(g, random);

        int knob = pieceKnob();
        int maxX = PUZZLE_W - PIECE - knob - 10;
        int puzzleX = random.nextInt(55, Math.max(56, maxX));
        int puzzleY = random.nextInt(knob + 6, PUZZLE_H - PIECE - 10);

        // 画布容纳顶部/右侧凸起；滑块图与缺口同形状
        int canvasW = jigsawCanvasSize();
        int canvasH = jigsawCanvasSize();
        Shape pieceShape = puzzleShape(0, knob, PIECE);

        BufferedImage piece = new BufferedImage(canvasW, canvasH, BufferedImage.TYPE_INT_ARGB);
        Graphics2D pg = piece.createGraphics();
        pg.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        // 从底图抠出拼图内容（像素级遮罩，保证透明通道正确）
        BufferedImage region = bg.getSubimage(puzzleX, puzzleY - knob, canvasW, canvasH);
        for (int y = 0; y < canvasH; y++) {
            for (int x = 0; x < canvasW; x++) {
                if (pieceShape.contains(x, y)) {
                    piece.setRGB(x, y, region.getRGB(x, y) | 0xFF000000);
                }
            }
        }

        // 描边 + 轻微内阴影，提升对齐手感
        pg.setStroke(new BasicStroke(1.8f));
        pg.setColor(new Color(255, 255, 255, 220));
        pg.draw(pieceShape);
        pg.setColor(new Color(0, 0, 0, 55));
        pg.setStroke(new BasicStroke(1.2f));
        pg.draw(pieceShape);
        pg.dispose();

        // 底图挖空（半透明暗槽）
        g.setComposite(AlphaComposite.SrcOver);
        g.setColor(new Color(0, 0, 0, 140));
        g.fill(puzzleShape(puzzleX, puzzleY, PIECE));
        g.setStroke(new BasicStroke(2f));
        g.setColor(new Color(255, 255, 255, 170));
        g.draw(puzzleShape(puzzleX, puzzleY, PIECE));
        g.dispose();

        // jigsawY = 拼图块画布顶部（含凸起），与 left=puzzleX 对齐缺口
        return new CaptchaImage(
                String.valueOf(puzzleX),
                toBase64(bg),
                "向右拖动滑块完成拼图",
                toBase64Png(piece),
                puzzleY - knob,
                null
        );
    }

    /**
     * ICEJZ 品牌风底图（对齐登录页青蓝科技调性）。
     * 主题：青雾晨曦 / 工作台浅色 / 深空冰蓝 / 冰川薄雾 /
     *       碧波层云 / 霜白面板 / 网格暮青 / 山峦青蓝。
     */
    private static void paintPuzzleBackground(Graphics2D g, Random random) {
        int theme = random.nextInt(8);
        // brand: #00a8e8 / #3ec6ff / #0f1724 / #e8f7fd / #f3f6fb
        Color skyTop;
        Color skyBottom;
        Color hillFar;
        Color hillNear;
        Color ground;
        Color orb;
        boolean night;
        boolean softLight;
        boolean grid;
        boolean waves;
        switch (theme) {
            case 0 -> { // 青雾晨曦
                skyTop = new Color(0x4B, 0xC4, 0xF0);
                skyBottom = new Color(0xE8, 0xF7, 0xFD);
                hillFar = new Color(0x2A, 0x9B, 0xC4);
                hillNear = new Color(0x08, 0x79, 0xA8);
                ground = new Color(0x06, 0x6A, 0x94);
                orb = new Color(0xFF, 0xF7, 0xD6);
                night = false;
                softLight = true;
                grid = false;
                waves = false;
            }
            case 1 -> { // 工作台浅色（canvas）
                skyTop = new Color(0xF3, 0xF6, 0xFB);
                skyBottom = new Color(0xE8, 0xF4, 0xFB);
                hillFar = new Color(0xC7, 0xE6, 0xF5);
                hillNear = new Color(0x9D, 0xD6, 0xEE);
                ground = new Color(0x7E, 0xC8, 0xE6);
                orb = new Color(0x00, 0xA8, 0xE8);
                night = false;
                softLight = true;
                grid = true;
                waves = false;
            }
            case 2 -> { // 深空冰蓝（登录页夜景）
                skyTop = new Color(0x03, 0x09, 0x12);
                skyBottom = new Color(0x0E, 0x24, 0x38);
                hillFar = new Color(0x0A, 0x2A, 0x42);
                hillNear = new Color(0x08, 0x1C, 0x2C);
                ground = new Color(0x05, 0x14, 0x20);
                orb = new Color(0x3E, 0xC6, 0xFF);
                night = true;
                softLight = false;
                grid = false;
                waves = false;
            }
            case 3 -> { // 冰川薄雾
                skyTop = new Color(0x6B, 0xB8, 0xD9);
                skyBottom = new Color(0xD7, 0xEA, 0xF6);
                hillFar = new Color(0x8A, 0xB8, 0xCC);
                hillNear = new Color(0x6A, 0x9E, 0xB8);
                ground = new Color(0xE8, 0xF0, 0xF6);
                orb = new Color(0xFF, 0xFF, 0xFF);
                night = false;
                softLight = true;
                grid = false;
                waves = false;
            }
            case 4 -> { // 碧波层云
                skyTop = new Color(0x1A, 0x8F, 0xC4);
                skyBottom = new Color(0x7E, 0xD4, 0xF0);
                hillFar = new Color(0x12, 0x7A, 0xA8);
                hillNear = new Color(0x0B, 0x66, 0x90);
                ground = new Color(0x08, 0x58, 0x7C);
                orb = new Color(0xB7, 0xE9, 0xFF);
                night = false;
                softLight = true;
                grid = false;
                waves = true;
            }
            case 5 -> { // 霜白面板
                skyTop = new Color(0xFA, 0xFC, 0xFE);
                skyBottom = new Color(0xE8, 0xF7, 0xFD);
                hillFar = new Color(0xD4, 0xEB, 0xF7);
                hillNear = new Color(0xB8, 0xDF, 0xF2);
                ground = new Color(0x9F, 0xD4, 0xEC);
                orb = new Color(0x3E, 0xC6, 0xFF);
                night = false;
                softLight = true;
                grid = true;
                waves = false;
            }
            case 6 -> { // 网格暮青
                skyTop = new Color(0x0A, 0x1E, 0x32);
                skyBottom = new Color(0x12, 0x3A, 0x52);
                hillFar = new Color(0x0E, 0x32, 0x48);
                hillNear = new Color(0x0A, 0x28, 0x3C);
                ground = new Color(0x07, 0x1C, 0x2C);
                orb = new Color(0x00, 0xA8, 0xE8);
                night = true;
                softLight = false;
                grid = true;
                waves = false;
            }
            default -> { // 山峦青蓝
                skyTop = new Color(0x38, 0xB6, 0xE0);
                skyBottom = new Color(0xC8, 0xEB, 0xF8);
                hillFar = new Color(0x2A, 0x8F, 0xB0);
                hillNear = new Color(0x1A, 0x72, 0x94);
                ground = new Color(0x14, 0x5E, 0x7A);
                orb = new Color(0xFF, 0xF4, 0xC8);
                night = false;
                softLight = true;
                grid = false;
                waves = false;
            }
        }

        g.setPaint(new GradientPaint(0, 0, skyTop, 0, PUZZLE_H, skyBottom));
        g.fillRect(0, 0, PUZZLE_W, PUZZLE_H);

        // 登录页同款径向光晕
        paintBrandGlow(g, random, night);

        // 主光球（太阳 / 冰蓝月）
        int orbX = random.nextInt(36, PUZZLE_W - 70);
        int orbY = random.nextInt(10, 40);
        int orbR = random.nextInt(13, 20);
        g.setColor(new Color(orb.getRed(), orb.getGreen(), orb.getBlue(), night ? 210 : 230));
        g.fillOval(orbX, orbY, orbR * 2, orbR * 2);
        g.setColor(new Color(orb.getRed(), orb.getGreen(), orb.getBlue(), night ? 45 : 55));
        g.fillOval(orbX - 8, orbY - 8, orbR * 2 + 16, orbR * 2 + 16);

        if (night) {
            for (int i = 0; i < 36; i++) {
                int a = 100 + random.nextInt(120);
                boolean cyan = random.nextBoolean();
                g.setColor(cyan ? new Color(0xB7, 0xE9, 0xFF, a) : new Color(255, 255, 255, a));
                g.fillOval(random.nextInt(PUZZLE_W), random.nextInt(78), 1 + random.nextInt(2), 1 + random.nextInt(2));
            }
        }

        if (grid) {
            paintBrandGrid(g, night);
        }

        // 远层山/云带
        g.setColor(hillFar);
        g.fill(buildSoftRidge(random, 0.36, 0.18, 28));

        // 近层
        g.setColor(hillNear);
        g.fill(buildSoftRidge(random, 0.50, 0.16, 22));

        // 地面 / 水面
        g.setColor(ground);
        g.fillRect(0, (int) (PUZZLE_H * 0.78), PUZZLE_W, PUZZLE_H);
        if (waves) {
            g.setStroke(new BasicStroke(1.2f));
            for (int i = 0; i < 6; i++) {
                int y = (int) (PUZZLE_H * 0.80) + i * 5;
                g.setColor(new Color(255, 255, 255, 36 + i * 6));
                g.drawLine(8, y, PUZZLE_W - 8, y + random.nextInt(-2, 3));
            }
        }

        // 前景点缀：青蓝针叶 / 霜丘 / 柔光柱
        for (int i = 0; i < 6; i++) {
            int tx = random.nextInt(8, PUZZLE_W - 18);
            int ty = (int) (PUZZLE_H * 0.72) + random.nextInt(6, 20);
            if (theme == 1 || theme == 5) {
                g.setColor(new Color(0x00, 0xA8, 0xE8, 90 + random.nextInt(60)));
                g.fillRoundRect(tx, ty - 10, 3, 16, 2, 2);
                g.setColor(new Color(0x3E, 0xC6, 0xFF, 70));
                g.fillOval(tx - 4, ty - 14, 12, 8);
            } else if (theme == 3) {
                g.setColor(new Color(0xB8, 0xD0, 0xE0, 180));
                g.fillOval(tx, ty, 16, 9);
            } else {
                g.setColor(night ? new Color(0x0A, 0x3A, 0x52) : new Color(0x0B, 0x5F, 0x7A));
                GeneralPath tree = new GeneralPath();
                tree.moveTo(tx + 6, ty - 15);
                tree.lineTo(tx - 1, ty + 4);
                tree.lineTo(tx + 13, ty + 4);
                tree.closePath();
                g.fill(tree);
                g.setColor(night ? new Color(0x1A, 0x3A, 0x4C) : new Color(0x2A, 0x4E, 0x5C));
                g.fillRect(tx + 4, ty + 2, 4, 7);
            }
        }

        if (softLight && !night) {
            g.setColor(new Color(255, 255, 255, theme == 1 || theme == 5 ? 110 : 150));
            for (int i = 0; i < 3; i++) {
                int cx = random.nextInt(PUZZLE_W - 70);
                int cy = random.nextInt(8, 48);
                g.fillOval(cx, cy, 40, 14);
                g.fillOval(cx + 14, cy - 5, 28, 16);
                g.fillOval(cx + 26, cy + 2, 24, 12);
            }
        }

        // 细噪点，避免纯矢量感
        for (int i = 0; i < 160; i++) {
            g.setColor(new Color(255, 255, 255, night ? 12 + random.nextInt(24) : 16 + random.nextInt(28)));
            g.fillRect(random.nextInt(PUZZLE_W), random.nextInt(PUZZLE_H), 1, 1);
        }
    }

    /** 登录页径向青蓝光晕 */
    private static void paintBrandGlow(Graphics2D g, Random random, boolean night) {
        int gx = random.nextInt(20, PUZZLE_W / 2);
        int gy = random.nextInt(0, 50);
        int gr = 70 + random.nextInt(50);
        g.setColor(night ? new Color(0x00, 0xA8, 0xE8, 55) : new Color(0x3E, 0xC6, 0xFF, 40));
        g.fillOval(gx - gr / 2, gy - gr / 3, gr, gr);
        int gx2 = PUZZLE_W - 40 - random.nextInt(80);
        int gy2 = PUZZLE_H - 50 - random.nextInt(30);
        g.setColor(night ? new Color(0x3E, 0xC6, 0xFF, 36) : new Color(0x00, 0xA8, 0xE8, 28));
        g.fillOval(gx2 - 40, gy2 - 30, 90, 70);
    }

    /** 低代码工作台风格浅网格 */
    private static void paintBrandGrid(Graphics2D g, boolean night) {
        g.setStroke(new BasicStroke(1f));
        g.setColor(night ? new Color(255, 255, 255, 18) : new Color(0x0F, 0x17, 0x24, 16));
        for (int x = 0; x < PUZZLE_W; x += 18) {
            g.drawLine(x, 0, x, PUZZLE_H);
        }
        for (int y = 0; y < PUZZLE_H; y += 18) {
            g.drawLine(0, y, PUZZLE_W, y);
        }
    }

    private static GeneralPath buildSoftRidge(Random random, double base, double amp, int step) {
        GeneralPath path = new GeneralPath();
        path.moveTo(0, PUZZLE_H);
        path.lineTo(0, PUZZLE_H * (base + 0.12));
        for (int x = 0; x <= PUZZLE_W; x += step) {
            double h = PUZZLE_H * (base + random.nextDouble() * amp);
            path.lineTo(x, h);
        }
        path.lineTo(PUZZLE_W, PUZZLE_H);
        path.closePath();
        return path;
    }

    /** 文字点选：风景底图散落文字，答案为 x1,y1|x2,y2|x3,y3 */
    private static CaptchaImage clickWord() {
        String[] pool = {"春", "夏", "秋", "冬", "东", "南", "西", "北", "云", "月", "星", "风", "花", "雪", "山", "水"};
        List<String> poolList = new ArrayList<>(List.of(pool));
        Collections.shuffle(poolList);
        List<String> targets = new ArrayList<>(poolList.subList(0, 3));

        BufferedImage image = new BufferedImage(CLICK_W, CLICK_H, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        Random random = RandomUtil.getRandom();
        paintPuzzleBackground(g, random);

        List<String> decoys = new ArrayList<>(poolList.subList(3, Math.min(9, poolList.size())));
        List<int[]> positions = new ArrayList<>();
        List<String> all = new ArrayList<>();
        all.addAll(targets);
        all.addAll(decoys);
        Collections.shuffle(all);

        Font font = new Font("SansSerif", Font.BOLD, 30);
        g.setFont(font);
        FontMetrics fm = g.getFontMetrics();
        java.util.Map<String, int[]> targetCenters = new java.util.LinkedHashMap<>();
        Color[] ink = {
                new Color(30, 58, 95),
                new Color(127, 29, 29),
                new Color(20, 83, 45),
                new Color(76, 29, 149),
                new Color(154, 52, 18)
        };
        for (String word : all) {
            int x;
            int y;
            int tries = 0;
            do {
                x = random.nextInt(28, CLICK_W - 44);
                y = random.nextInt(40, CLICK_H - 18);
                tries++;
            } while (tries < 50 && tooClose(positions, x, y, 46));
            positions.add(new int[]{x, y});
            int cx = x + fm.stringWidth(word) / 2;
            int cy = y - fm.getAscent() / 3;
            double angle = Math.toRadians(random.nextInt(-35, 36));
            AffineTransform old = g.getTransform();
            g.rotate(angle, cx, cy);
            g.setColor(new Color(0, 0, 0, 45));
            g.drawString(word, x + 1, y + 2);
            g.setColor(ink[random.nextInt(ink.length)]);
            g.drawString(word, x, y);
            g.setTransform(old);
            if (targets.contains(word) && !targetCenters.containsKey(word)) {
                targetCenters.put(word, new int[]{cx, cy});
            }
        }
        g.dispose();

        List<String> pointParts = new ArrayList<>();
        for (String t : targets) {
            int[] p = targetCenters.get(t);
            pointParts.add(p[0] + "," + p[1]);
        }

        String tip = "请依次点击：" + String.join("、", targets);
        return new CaptchaImage(
                String.join("|", pointParts),
                toBase64(image),
                tip,
                null,
                null,
                targets
        );
    }

    private static boolean tooClose(List<int[]> positions, int x, int y, int min) {
        for (int[] p : positions) {
            if (Math.hypot(p[0] - x, p[1] - y) < min) {
                return true;
            }
        }
        return false;
    }

    /** AJ-Captcha 风格拼图轮廓：上凸起 + 右凸起 */
    private static Shape puzzleShape(int x, int y, int size) {
        int r = Math.max(6, size / 5);
        GeneralPath path = new GeneralPath();
        path.moveTo(x, y);
        path.lineTo(x + size / 2.0 - r, y);
        // 上凸起
        path.curveTo(x + size / 2.0 - r, y - r, x + size / 2.0 + r, y - r, x + size / 2.0 + r, y);
        path.lineTo(x + size, y);
        path.lineTo(x + size, y + size / 2.0 - r);
        // 右凸起
        path.curveTo(x + size + r, y + size / 2.0 - r, x + size + r, y + size / 2.0 + r, x + size, y + size / 2.0 + r);
        path.lineTo(x + size, y + size);
        path.lineTo(x, y + size);
        path.closePath();
        return path;
    }

    /** 软质感图标：阴影 + 高饱和填充 + 描边 */
    private static void drawSoftIcon(Graphics2D g, String name, Color color, int cx, int cy, int r) {
        if (isCompositeIcon(name)) {
            drawCompositeIcon(g, name, color, cx, cy, r);
            return;
        }

        Shape shape = softIconShape(name, cx, cy, r);
        g.setColor(new Color(0, 0, 0, 50));
        g.fill(AffineTransform.getTranslateInstance(1.6, 2.2).createTransformedShape(shape));

        Paint fill = new GradientPaint(cx - r, cy - r, lighter(color, 0.18f), cx + r, cy + r, color);
        g.setPaint(fill);
        if ("花朵".equals(name)) {
            for (int i = 0; i < 5; i++) {
                double a = -Math.PI / 2 + i * Math.PI * 2 / 5;
                double px = cx + Math.cos(a) * r * 0.58;
                double py = cy + Math.sin(a) * r * 0.58;
                g.fill(new Ellipse2D.Double(px - r * 0.4, py - r * 0.4, r * 0.8, r * 0.8));
            }
            g.setColor(lighter(color, 0.55f));
            g.fill(new Ellipse2D.Double(cx - r * 0.28, cy - r * 0.28, r * 0.56, r * 0.56));
        } else {
            g.fill(shape);
        }

        g.setStroke(new BasicStroke(1.5f));
        g.setColor(new Color(255, 255, 255, 210));
        g.draw(shape);
        g.setColor(new Color(255, 255, 255, 95));
        g.fill(new Ellipse2D.Double(cx - r * 0.42, cy - r * 0.55, r * 0.5, r * 0.32));
    }

    private static boolean isCompositeIcon(String name) {
        return switch (name) {
            case "单车", "小汽车", "大货车", "飞机", "帆船", "房子", "雨伞",
                 "星星", "铃铛", "钥匙", "茶杯", "气球", "皇冠", "盾牌", "闪电", "蘑菇", "蝴蝶" -> true;
            default -> false;
        };
    }

    private static void drawCompositeIcon(Graphics2D g, String name, Color color, int cx, int cy, int r) {
        g.setColor(new Color(0, 0, 0, 40));
        switch (name) {
            case "单车" -> {
                g.fillOval(cx - r - 1, cy + 2, (int) (r * 0.95), (int) (r * 0.95));
                g.fillOval(cx + 2, cy + 2, (int) (r * 0.95), (int) (r * 0.95));
            }
            case "小汽车", "大货车" -> g.fillRoundRect(cx - r, cy - r / 3 + 2, r * 2, (int) (r * 1.05), 8, 8);
            case "飞机" -> g.fillOval(cx - r / 2, cy - r / 4 + 2, r, r / 2);
            case "帆船" -> g.fillOval(cx - r, cy + 2, r * 2, r);
            case "房子" -> g.fillRect(cx - r + 2, cy - 2, r * 2 - 2, r + 4);
            case "雨伞" -> g.fillArc(cx - r, cy - r / 2 + 2, r * 2, r + 4, 0, 180);
            case "星星", "皇冠", "盾牌", "闪电", "蝴蝶" -> g.fill(softIconShape(name, cx, cy + 2, r));
            case "铃铛", "气球", "蘑菇" -> g.fillOval(cx - r + 1, cy - r / 2 + 2, r * 2 - 2, r + 6);
            case "钥匙", "茶杯" -> g.fillRoundRect(cx - r + 2, cy - r / 3 + 2, r * 2 - 4, r, 6, 6);
            default -> {
            }
        }

        Paint fill = new GradientPaint(cx - r, cy - r, lighter(color, 0.28f), cx + r, cy + r, color);
        g.setPaint(fill);
        g.setStroke(new BasicStroke(1.6f));
        Color ink = new Color(30, 41, 59, 200);

        switch (name) {
            case "单车" -> {
                g.setStroke(new BasicStroke(2.2f));
                g.draw(new Ellipse2D.Double(cx - r * 1.05, cy + r * 0.05, r * 0.95, r * 0.95));
                g.draw(new Ellipse2D.Double(cx + r * 0.1, cy + r * 0.05, r * 0.95, r * 0.95));
                g.setStroke(new BasicStroke(2f));
                g.drawLine(cx - (int) (r * 0.55), cy + (int) (r * 0.5), cx + (int) (r * 0.55), cy + (int) (r * 0.5));
                g.drawLine(cx - (int) (r * 0.2), cy + (int) (r * 0.5), cx - (int) (r * 0.05), cy - (int) (r * 0.35));
                g.drawLine(cx + (int) (r * 0.55), cy + (int) (r * 0.5), cx + (int) (r * 0.15), cy - (int) (r * 0.15));
                g.drawLine(cx - (int) (r * 0.05), cy - (int) (r * 0.35), cx + (int) (r * 0.35), cy - (int) (r * 0.35));
                g.setColor(ink);
                g.fillOval(cx - (int) (r * 0.12), cy - (int) (r * 0.42), 5, 5);
            }
            case "小汽车" -> {
                g.fillRoundRect(cx - r, cy - (int) (r * 0.15), r * 2, (int) (r * 0.85), 10, 10);
                g.fillRoundRect(cx - (int) (r * 0.55), cy - (int) (r * 0.7), (int) (r * 1.1), (int) (r * 0.55), 8, 8);
                g.setColor(new Color(255, 255, 255, 180));
                g.fillRoundRect(cx - (int) (r * 0.42), cy - (int) (r * 0.58), (int) (r * 0.35), (int) (r * 0.32), 4, 4);
                g.fillRoundRect(cx + (int) (r * 0.05), cy - (int) (r * 0.58), (int) (r * 0.35), (int) (r * 0.32), 4, 4);
                g.setColor(ink);
                g.fillOval(cx - (int) (r * 0.7), cy + (int) (r * 0.35), (int) (r * 0.55), (int) (r * 0.55));
                g.fillOval(cx + (int) (r * 0.2), cy + (int) (r * 0.35), (int) (r * 0.55), (int) (r * 0.55));
                g.setColor(new Color(255, 255, 255, 200));
                g.fillOval(cx - (int) (r * 0.58), cy + (int) (r * 0.47), (int) (r * 0.28), (int) (r * 0.28));
                g.fillOval(cx + (int) (r * 0.32), cy + (int) (r * 0.47), (int) (r * 0.28), (int) (r * 0.28));
            }
            case "大货车" -> {
                g.fillRoundRect(cx - r, cy - (int) (r * 0.35), (int) (r * 1.25), (int) (r * 1.05), 6, 6);
                g.fillRoundRect(cx + (int) (r * 0.2), cy - (int) (r * 0.05), (int) (r * 0.85), (int) (r * 0.75), 6, 6);
                g.setColor(new Color(255, 255, 255, 170));
                g.fillRoundRect(cx + (int) (r * 0.35), cy + (int) (r * 0.05), (int) (r * 0.45), (int) (r * 0.35), 4, 4);
                g.setColor(ink);
                g.fillOval(cx - (int) (r * 0.75), cy + (int) (r * 0.4), (int) (r * 0.5), (int) (r * 0.5));
                g.fillOval(cx - (int) (r * 0.15), cy + (int) (r * 0.4), (int) (r * 0.5), (int) (r * 0.5));
                g.fillOval(cx + (int) (r * 0.45), cy + (int) (r * 0.4), (int) (r * 0.5), (int) (r * 0.5));
            }
            case "飞机" -> {
                GeneralPath body = new GeneralPath();
                body.moveTo(cx + r, cy);
                body.curveTo(cx + r * 0.2, cy - r * 0.35, cx - r * 0.6, cy - r * 0.25, cx - r, cy);
                body.curveTo(cx - r * 0.6, cy + r * 0.25, cx + r * 0.2, cy + r * 0.35, cx + r, cy);
                body.closePath();
                g.fill(body);
                GeneralPath wing = new GeneralPath();
                wing.moveTo(cx - r * 0.1, cy);
                wing.lineTo(cx - r * 0.55, cy - r * 0.95);
                wing.lineTo(cx + r * 0.25, cy);
                wing.lineTo(cx - r * 0.55, cy + r * 0.95);
                wing.closePath();
                g.fill(wing);
                g.setColor(new Color(255, 255, 255, 180));
                g.fillOval(cx + (int) (r * 0.25), cy - 3, 7, 6);
            }
            case "帆船" -> {
                GeneralPath hull = new GeneralPath();
                hull.moveTo(cx - r, cy + r * 0.35);
                hull.lineTo(cx + r, cy + r * 0.35);
                hull.lineTo(cx + r * 0.55, cy + r * 0.95);
                hull.lineTo(cx - r * 0.55, cy + r * 0.95);
                hull.closePath();
                g.fill(hull);
                g.setColor(ink);
                g.setStroke(new BasicStroke(2f));
                g.drawLine(cx, cy + (int) (r * 0.35), cx, cy - r);
                g.setPaint(fill);
                GeneralPath sail = new GeneralPath();
                sail.moveTo(cx + 1, cy - r);
                sail.lineTo(cx + r * 0.85, cy + r * 0.2);
                sail.lineTo(cx + 1, cy + r * 0.2);
                sail.closePath();
                g.fill(sail);
            }
            case "房子" -> {
                g.fillRect(cx - (int) (r * 0.75), cy - (int) (r * 0.1), (int) (r * 1.5), (int) (r * 1.05));
                GeneralPath roof = new GeneralPath();
                roof.moveTo(cx, cy - r);
                roof.lineTo(cx + r, cy - (int) (r * 0.05));
                roof.lineTo(cx - r, cy - (int) (r * 0.05));
                roof.closePath();
                g.fill(roof);
                g.setColor(new Color(255, 255, 255, 190));
                g.fillRect(cx - (int) (r * 0.2), cy + (int) (r * 0.25), (int) (r * 0.4), (int) (r * 0.55));
                g.fillRect(cx - (int) (r * 0.55), cy + (int) (r * 0.05), (int) (r * 0.28), (int) (r * 0.28));
            }
            case "雨伞" -> {
                g.setPaint(fill);
                g.fillArc(cx - r, cy - (int) (r * 0.5), r * 2, (int) (r * 1.25), 0, 180);
                g.setColor(new Color(255, 255, 255, 160));
                g.setStroke(new BasicStroke(1.4f));
                g.drawLine(cx - (int) (r * 0.55), cy + (int) (r * 0.05), cx, cy - (int) (r * 0.35));
                g.drawLine(cx + (int) (r * 0.55), cy + (int) (r * 0.05), cx, cy - (int) (r * 0.35));
                g.drawLine(cx, cy + (int) (r * 0.08), cx, cy - (int) (r * 0.35));
                g.setColor(ink);
                g.setStroke(new BasicStroke(2.4f));
                g.drawLine(cx, cy + (int) (r * 0.05), cx, cy + (int) (r * 0.95));
                g.drawArc(cx, cy + (int) (r * 0.7), (int) (r * 0.48), (int) (r * 0.48), 200, 130);
                g.setColor(new Color(255, 255, 255, 220));
                g.setStroke(new BasicStroke(1.8f));
                g.drawArc(cx - r, cy - (int) (r * 0.5), r * 2, (int) (r * 1.25), 0, 180);
            }
            case "星星" -> {
                Shape star = starPath(cx, cy, r);
                g.fill(star);
                g.setColor(new Color(255, 255, 255, 210));
                g.setStroke(new BasicStroke(1.5f));
                g.draw(star);
            }
            case "铃铛" -> {
                g.fillOval(cx - (int) (r * 0.85), cy - (int) (r * 0.55), (int) (r * 1.7), (int) (r * 1.35));
                g.fillRect(cx - (int) (r * 0.95), cy + (int) (r * 0.45), (int) (r * 1.9), (int) (r * 0.28));
                g.setColor(ink);
                g.fillOval(cx - 3, cy + (int) (r * 0.7), 6, 6);
                g.setStroke(new BasicStroke(2f));
                g.drawArc(cx - 6, cy - r, 12, 12, 0, 180);
            }
            case "钥匙" -> {
                g.fillOval(cx - r, cy - (int) (r * 0.55), (int) (r * 0.95), (int) (r * 0.95));
                g.setColor(new Color(255, 255, 255, 200));
                g.fillOval(cx - (int) (r * 0.72), cy - (int) (r * 0.28), (int) (r * 0.4), (int) (r * 0.4));
                g.setPaint(fill);
                g.fillRoundRect(cx - (int) (r * 0.15), cy - (int) (r * 0.18), (int) (r * 1.2), (int) (r * 0.36), 4, 4);
                g.fillRect(cx + (int) (r * 0.55), cy - (int) (r * 0.18), (int) (r * 0.22), (int) (r * 0.55));
                g.fillRect(cx + (int) (r * 0.85), cy - (int) (r * 0.18), (int) (r * 0.22), (int) (r * 0.4));
            }
            case "茶杯" -> {
                g.fillRoundRect(cx - (int) (r * 0.7), cy - (int) (r * 0.35), (int) (r * 1.25), (int) (r * 1.15), 8, 8);
                g.setStroke(new BasicStroke(2.4f));
                g.drawArc(cx + (int) (r * 0.45), cy - (int) (r * 0.15), (int) (r * 0.55), (int) (r * 0.7), 270, 180);
                g.setColor(new Color(255, 255, 255, 170));
                g.fillRoundRect(cx - (int) (r * 0.55), cy - (int) (r * 0.15), (int) (r * 0.95), (int) (r * 0.28), 4, 4);
            }
            case "气球" -> {
                g.fillOval(cx - (int) (r * 0.75), cy - r, (int) (r * 1.5), (int) (r * 1.55));
                GeneralPath knot = new GeneralPath();
                knot.moveTo(cx, cy + (int) (r * 0.5));
                knot.lineTo(cx - (int) (r * 0.25), cy + (int) (r * 0.78));
                knot.lineTo(cx + (int) (r * 0.25), cy + (int) (r * 0.78));
                knot.closePath();
                g.fill(knot);
                g.setColor(ink);
                g.setStroke(new BasicStroke(1.8f));
                g.drawLine(cx, cy + (int) (r * 0.78), cx, cy + r);
                g.setColor(new Color(255, 255, 255, 190));
                g.fillOval(cx - (int) (r * 0.4), cy - (int) (r * 0.65), (int) (r * 0.35), (int) (r * 0.45));
            }
            case "皇冠" -> {
                GeneralPath crown = crownPath(cx, cy, r);
                g.fill(crown);
                g.setColor(new Color(255, 255, 255, 210));
                g.fillOval(cx - 3, cy - (int) (r * 0.55), 6, 6);
                g.fillOval(cx - (int) (r * 0.55), cy - (int) (r * 0.15), 5, 5);
                g.fillOval(cx + (int) (r * 0.4), cy - (int) (r * 0.15), 5, 5);
            }
            case "盾牌" -> {
                Shape shield = shieldPath(cx, cy, r);
                g.fill(shield);
                g.setColor(new Color(255, 255, 255, 200));
                g.setStroke(new BasicStroke(2f));
                g.draw(shield);
                g.drawLine(cx, cy - (int) (r * 0.45), cx, cy + (int) (r * 0.55));
                g.drawLine(cx - (int) (r * 0.4), cy - (int) (r * 0.05), cx + (int) (r * 0.4), cy - (int) (r * 0.05));
            }
            case "闪电" -> {
                Shape bolt = lightningPath(cx, cy, r);
                g.fill(bolt);
                g.setColor(new Color(255, 255, 255, 200));
                g.setStroke(new BasicStroke(1.4f));
                g.draw(bolt);
            }
            case "蘑菇" -> {
                g.fillArc(cx - r, cy - (int) (r * 0.85), r * 2, (int) (r * 1.4), 0, 180);
                g.setColor(new Color(255, 248, 230));
                g.fillRoundRect(cx - (int) (r * 0.4), cy - (int) (r * 0.05), (int) (r * 0.8), (int) (r * 0.95), 8, 8);
                g.setColor(new Color(255, 255, 255, 210));
                g.fillOval(cx - (int) (r * 0.55), cy - (int) (r * 0.45), (int) (r * 0.35), (int) (r * 0.28));
                g.fillOval(cx + (int) (r * 0.15), cy - (int) (r * 0.55), (int) (r * 0.28), (int) (r * 0.22));
            }
            case "蝴蝶" -> {
                g.fill(new Ellipse2D.Double(cx - r * 1.05, cy - r * 0.75, r * 0.9, r * 0.95));
                g.fill(new Ellipse2D.Double(cx + r * 0.15, cy - r * 0.75, r * 0.9, r * 0.95));
                g.fill(new Ellipse2D.Double(cx - r * 0.95, cy + r * 0.05, r * 0.75, r * 0.7));
                g.fill(new Ellipse2D.Double(cx + r * 0.2, cy + r * 0.05, r * 0.75, r * 0.7));
                g.setColor(ink);
                g.fillRoundRect(cx - 2, cy - (int) (r * 0.7), 4, (int) (r * 1.4), 4, 4);
                g.setStroke(new BasicStroke(1.6f));
                g.drawLine(cx, cy - (int) (r * 0.7), cx - 6, cy - r);
                g.drawLine(cx, cy - (int) (r * 0.7), cx + 6, cy - r);
            }
            default -> g.fill(new Ellipse2D.Double(cx - r, cy - r, r * 2.0, r * 2.0));
        }
    }

    private static Shape softIconShape(String name, int cx, int cy, int r) {
        return switch (name) {
            case "爱心" -> heartPath(cx, cy, r);
            case "花朵" -> new Ellipse2D.Double(cx - r, cy - r, r * 2.0, r * 2.0);
            case "小鱼" -> fishPath(cx, cy, r);
            case "叶子" -> leafPath(cx, cy, r);
            case "月亮" -> moonPath(cx, cy, r);
            case "星星" -> starPath(cx, cy, r);
            case "皇冠" -> crownPath(cx, cy, r);
            case "盾牌" -> shieldPath(cx, cy, r);
            case "闪电" -> lightningPath(cx, cy, r);
            case "蝴蝶" -> new Ellipse2D.Double(cx - r, cy - r * 0.7, r * 2.0, r * 1.4);
            default -> new Ellipse2D.Double(cx - r, cy - r, r * 2.0, r * 2.0);
        };
    }

    private static GeneralPath starPath(int cx, int cy, int r) {
        GeneralPath path = new GeneralPath();
        for (int i = 0; i < 5; i++) {
            double outer = Math.toRadians(-90 + i * 72);
            double inner = Math.toRadians(-90 + i * 72 + 36);
            double ox = cx + r * Math.cos(outer);
            double oy = cy + r * Math.sin(outer);
            double ix = cx + r * 0.42 * Math.cos(inner);
            double iy = cy + r * 0.42 * Math.sin(inner);
            if (i == 0) {
                path.moveTo(ox, oy);
            } else {
                path.lineTo(ox, oy);
            }
            path.lineTo(ix, iy);
        }
        path.closePath();
        return path;
    }

    private static GeneralPath crownPath(int cx, int cy, int r) {
        GeneralPath path = new GeneralPath();
        path.moveTo(cx - r, cy + r * 0.55);
        path.lineTo(cx - r, cy - r * 0.1);
        path.lineTo(cx - r * 0.55, cy + r * 0.15);
        path.lineTo(cx, cy - r * 0.75);
        path.lineTo(cx + r * 0.55, cy + r * 0.15);
        path.lineTo(cx + r, cy - r * 0.1);
        path.lineTo(cx + r, cy + r * 0.55);
        path.closePath();
        return path;
    }

    private static GeneralPath shieldPath(int cx, int cy, int r) {
        GeneralPath path = new GeneralPath();
        path.moveTo(cx, cy - r * 0.85);
        path.curveTo(cx + r * 0.85, cy - r * 0.7, cx + r * 0.9, cy - r * 0.1, cx + r * 0.75, cy + r * 0.25);
        path.curveTo(cx + r * 0.45, cy + r * 0.75, cx, cy + r, cx, cy + r);
        path.curveTo(cx, cy + r, cx - r * 0.45, cy + r * 0.75, cx - r * 0.75, cy + r * 0.25);
        path.curveTo(cx - r * 0.9, cy - r * 0.1, cx - r * 0.85, cy - r * 0.7, cx, cy - r * 0.85);
        path.closePath();
        return path;
    }

    private static GeneralPath lightningPath(int cx, int cy, int r) {
        GeneralPath path = new GeneralPath();
        path.moveTo(cx + r * 0.15, cy - r);
        path.lineTo(cx - r * 0.35, cy - r * 0.05);
        path.lineTo(cx + r * 0.05, cy - r * 0.05);
        path.lineTo(cx - r * 0.2, cy + r);
        path.lineTo(cx + r * 0.45, cy - r * 0.2);
        path.lineTo(cx + r * 0.05, cy - r * 0.2);
        path.closePath();
        return path;
    }

    private static Color lighter(Color c, float amount) {
        int rr = Math.min(255, (int) (c.getRed() + (255 - c.getRed()) * amount));
        int gg = Math.min(255, (int) (c.getGreen() + (255 - c.getGreen()) * amount));
        int bb = Math.min(255, (int) (c.getBlue() + (255 - c.getBlue()) * amount));
        return new Color(rr, gg, bb);
    }

    private static GeneralPath heartPath(int cx, int cy, int r) {
        GeneralPath path = new GeneralPath();
        path.moveTo(cx, cy + r * 0.72);
        path.curveTo(cx - r * 1.25, cy + r * 0.08, cx - r * 1.05, cy - r * 0.9, cx, cy - r * 0.22);
        path.curveTo(cx + r * 1.05, cy - r * 0.9, cx + r * 1.25, cy + r * 0.08, cx, cy + r * 0.72);
        path.closePath();
        return path;
    }

    private static GeneralPath fishPath(int cx, int cy, int r) {
        GeneralPath path = new GeneralPath();
        path.moveTo(cx - r * 0.9, cy);
        path.curveTo(cx - r * 0.55, cy - r * 0.7, cx + r * 0.25, cy - r * 0.65, cx + r * 0.45, cy);
        path.curveTo(cx + r * 0.25, cy + r * 0.65, cx - r * 0.55, cy + r * 0.7, cx - r * 0.9, cy);
        path.closePath();
        path.moveTo(cx + r * 0.35, cy);
        path.lineTo(cx + r * 1.05, cy - r * 0.55);
        path.lineTo(cx + r * 0.85, cy);
        path.lineTo(cx + r * 1.05, cy + r * 0.55);
        path.closePath();
        return path;
    }

    private static GeneralPath leafPath(int cx, int cy, int r) {
        // 侧向叶片 + 叶尖，避免竖着时被认成雨伞
        GeneralPath path = new GeneralPath();
        path.moveTo(cx - r * 0.9, cy);
        path.curveTo(cx - r * 0.2, cy - r * 1.05, cx + r * 0.85, cy - r * 0.55, cx + r, cy);
        path.curveTo(cx + r * 0.85, cy + r * 0.55, cx - r * 0.2, cy + r * 1.05, cx - r * 0.9, cy);
        path.closePath();
        return path;
    }

    private static Shape moonPath(int cx, int cy, int r) {
        Area moon = new Area(new Ellipse2D.Double(cx - r, cy - r, r * 2.0, r * 2.0));
        moon.subtract(new Area(new Ellipse2D.Double(cx - r * 0.1, cy - r * 1.05, r * 2.05, r * 2.05)));
        return moon;
    }

    /**
     * 滑动曲线：底图两端固定端点 + 淡色目标绳影；
     * 亮色 V 绳两端始终钉在端点上，拖动滑块只摆动中点，对齐绳影后通过。
     * words: leftX,leftY | rightX,rightY | deepY | vertexBase,travel
     * 答案为中点相对 vertexBase 的水平偏移（与拼图滑块相同）。
     */
    private static CaptchaImage curveMatch() {
        Random random = RandomUtil.getRandom();
        BufferedImage bg = new BufferedImage(PUZZLE_W, PUZZLE_H, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = bg.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_STROKE_CONTROL, RenderingHints.VALUE_STROKE_PURE);
        paintPuzzleBackground(g, random);

        int leftX = 14 + random.nextInt(10);
        int rightX = PUZZLE_W - 14 - random.nextInt(10);
        int leftY = 20 + random.nextInt(10);
        int rightY = 20 + random.nextInt(10);
        int deepY = PUZZLE_H - 22 - random.nextInt(10);
        int vertexBase = leftX + 28;
        int vertexCeil = rightX - 28;
        int travel = Math.max(48, vertexCeil - vertexBase);
        // 答案至少离开起点一段距离，避免开局中点已对齐
        int minAnswer = Math.max(36, Math.min(travel / 3, travel - 20));
        if (minAnswer >= travel) {
            minAnswer = Math.max(20, travel / 2);
        }
        int answerX = random.nextInt(minAnswer, Math.max(minAnswer + 1, travel + 1));
        int answerVertexX = vertexBase + answerX;

        Shape ghost = buildVRopePath(leftX, leftY, answerVertexX, deepY, rightX, rightY);
        g.setStroke(new BasicStroke(12f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND));
        g.setColor(new Color(0, 0, 0, 55));
        g.draw(ghost);
        g.setStroke(new BasicStroke(5f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND));
        g.setColor(new Color(255, 255, 255, 70));
        g.draw(ghost);
        drawCurveEndpoint(g, leftX, leftY, true);
        drawCurveEndpoint(g, rightX, rightY, false);
        g.dispose();

        List<String> words = new ArrayList<>(4);
        words.add(leftX + "," + leftY);
        words.add(rightX + "," + rightY);
        words.add(String.valueOf(deepY));
        words.add(vertexBase + "," + travel);

        return new CaptchaImage(
                String.valueOf(answerX),
                toBase64(bg),
                "拖动滑块摆动绳子，使中点对齐",
                null,
                null,
                words
        );
    }

    /**
     * V 形绳子：两端固定、中点下探；控制点偏下形成悬垂感，避免生硬折线。
     * 公式需与各端前端 buildVRope 保持一致。
     */
    private static Shape buildVRopePath(int leftX, int leftY, int vertexX, int vertexY, int rightX, int rightY) {
        GeneralPath path = new GeneralPath();
        path.moveTo(leftX, leftY);
        path.curveTo(
                leftX + (vertexX - leftX) * 0.30, leftY + (vertexY - leftY) * 0.68,
                vertexX - (vertexX - leftX) * 0.36, vertexY - (vertexY - leftY) * 0.04,
                vertexX, vertexY
        );
        path.curveTo(
                vertexX + (rightX - vertexX) * 0.36, vertexY - (vertexY - rightY) * 0.04,
                rightX - (rightX - vertexX) * 0.30, rightY + (vertexY - rightY) * 0.68,
                rightX, rightY
        );
        return path;
    }

    /** 绳子端点（白点） */
    private static void drawCurveEndpoint(Graphics2D g, int x, int y, boolean start) {
        int r = start ? 7 : 8;
        g.setColor(new Color(255, 255, 255, 50));
        g.fill(new Ellipse2D.Double(x - r - 3, y - r - 3, (r + 3) * 2.0, (r + 3) * 2.0));
        g.setColor(new Color(255, 255, 255, 240));
        g.fill(new Ellipse2D.Double(x - r, y - r, r * 2.0, r * 2.0));
        g.setColor(new Color(255, 255, 255, 170));
        g.setStroke(new BasicStroke(1.6f));
        g.draw(new Ellipse2D.Double(x - r - 1, y - r - 1, (r + 1) * 2.0, (r + 1) * 2.0));
    }

    /**
     * 旋转验证码：随机旋转艺术图，答案为服务端旋转角；用户回传补正角。
     */
    private static CaptchaImage rotateCaptcha() {
        Random random = RandomUtil.getRandom();
        int angle = randomAngle(random);
        BufferedImage src = createRotateArt(ROTATE_SIZE, random);
        BufferedImage rotated = rotateSquare(src, angle);
        return new CaptchaImage(String.valueOf(angle), toBase64(rotated), "拖动滑块将图片旋转至正向");
    }

    /**
     * 角度验证码：表盘指针偏离正上方，用户旋转至 12 点方向。
     */
    private static CaptchaImage angleCaptcha() {
        Random random = RandomUtil.getRandom();
        int angle = randomAngle(random);
        BufferedImage dial = createAngleDial(ROTATE_SIZE, angle, random);
        return new CaptchaImage(String.valueOf(angle), toBase64(dial), "拖动滑块旋转指针至正上方");
    }

    private static int randomAngle(Random random) {
        int angle = random.nextInt(4, 33) * 10; // 40~320
        if (angle >= 170 && angle <= 190) {
            angle = angle <= 180 ? 150 : 210;
        }
        return angle;
    }

    private static BufferedImage createRotateArt(int size, Random random) {
        BufferedImage img = new BufferedImage(size, size, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        // 多种「正立方向明确」的图案，随机抽取
        switch (random.nextInt(12)) {
            case 0 -> paintRotateFlagTop(g, size, random);
            case 1 -> paintRotateMountain(g, size, random);
            case 2 -> paintRotateHouse(g, size, random);
            case 3 -> paintRotateTree(g, size, random);
            case 4 -> paintRotateRocket(g, size, random);
            case 5 -> paintRotateSailboat(g, size, random);
            case 6 -> paintRotateBalloon(g, size, random);
            case 7 -> paintRotateIceCream(g, size, random);
            case 8 -> paintRotateUmbrella(g, size, random);
            case 9 -> paintRotateFlower(g, size, random);
            case 10 -> paintRotateArrow(g, size, random);
            default -> paintRotateLighthouse(g, size, random);
        }
        // 统一边框，帮助识别画布边界
        g.setStroke(new BasicStroke(3f));
        g.setColor(new Color(255, 255, 255, 160));
        g.drawRoundRect(8, 8, size - 16, size - 16, 22, 22);
        g.dispose();
        return img;
    }

    private static void fillRotateBg(Graphics2D g, int size, Color c1, Color c2) {
        g.setPaint(new GradientPaint(0, 0, c1, size, size, c2));
        g.fillRect(0, 0, size, size);
    }

    private static void paintRotateSoftBubbles(Graphics2D g, int size, Random random, int count) {
        for (int i = 0; i < count; i++) {
            g.setColor(new Color(255, 255, 255, 28 + random.nextInt(40)));
            int r = 16 + random.nextInt(36);
            g.fillOval(random.nextInt(Math.max(1, size - r)), random.nextInt(Math.max(1, size - r)), r, r);
        }
    }

    /** 顶部三角旗 + TOP 条（经典正向标记） */
    private static void paintRotateFlagTop(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(14, 165, 233), new Color(16, 185, 129));
        paintRotateSoftBubbles(g, size, random, 5);
        g.setColor(new Color(255, 255, 255, 230));
        g.fillPolygon(new int[]{size / 2, size / 2 - 18, size / 2 + 18}, new int[]{18, 48, 48}, 3);
        g.setColor(new Color(255, 255, 255, 200));
        g.fillRoundRect(size / 2 - 36, size - 42, 72, 22, 10, 10);
        g.setColor(new Color(15, 23, 42));
        g.setFont(new Font("SansSerif", Font.BOLD, 12));
        g.drawString("TOP", size / 2 - 14, size - 26);
    }

    /** 雪山：峰顶朝上、地面在下 */
    private static void paintRotateMountain(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(56, 189, 248), new Color(186, 230, 253));
        // 太阳偏上
        g.setColor(new Color(253, 224, 71));
        g.fillOval(size - 70, 22, 36, 36);
        g.setColor(new Color(34, 197, 94));
        g.fillRect(0, size - 48, size, 48);
        g.setColor(new Color(148, 163, 184));
        g.fillPolygon(new int[]{20, size / 2, size - 16}, new int[]{size - 40, 36, size - 40}, 3);
        g.setColor(new Color(248, 250, 252));
        g.fillPolygon(new int[]{size / 2 - 18, size / 2, size / 2 + 22}, new int[]{78, 36, 86}, 3);
        paintRotateSoftBubbles(g, size, random, 3);
    }

    /** 小屋：屋顶朝上 */
    private static void paintRotateHouse(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(125, 211, 252), new Color(224, 242, 254));
        g.setColor(new Color(74, 222, 128));
        g.fillRect(0, size - 36, size, 36);
        int cx = size / 2;
        g.setColor(new Color(251, 146, 60));
        g.fillPolygon(new int[]{cx - 62, cx, cx + 62}, new int[]{88, 28, 88}, 3);
        g.setColor(new Color(254, 243, 199));
        g.fillRoundRect(cx - 46, 86, 92, 70, 8, 8);
        g.setColor(new Color(56, 189, 248));
        g.fillRoundRect(cx - 16, 102, 32, 28, 6, 6);
        g.setColor(new Color(180, 83, 9));
        g.fillRect(cx + 18, 118, 22, 38);
        paintRotateSoftBubbles(g, size, random, 2);
    }

    /** 树木：树冠在上、树干在下 */
    private static void paintRotateTree(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(186, 230, 253), new Color(224, 242, 254));
        g.setColor(new Color(134, 239, 172));
        g.fillRect(0, size - 40, size, 40);
        int cx = size / 2;
        g.setColor(new Color(180, 83, 9));
        g.fillRoundRect(cx - 10, size - 88, 20, 52, 6, 6);
        g.setColor(new Color(22, 163, 74));
        g.fillOval(cx - 48, 34, 96, 86);
        g.setColor(new Color(34, 197, 94));
        g.fillOval(cx - 36, 22, 72, 64);
        g.setColor(new Color(253, 224, 71));
        g.fillOval(28, 28, 22, 22);
        paintRotateSoftBubbles(g, size, random, 2);
    }

    /** 火箭：尖头朝上 */
    private static void paintRotateRocket(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(15, 23, 42), new Color(30, 58, 138));
        // 星星点缀
        g.setColor(new Color(255, 255, 255, 180));
        for (int i = 0; i < 10; i++) {
            g.fillOval(12 + random.nextInt(size - 24), 12 + random.nextInt(size - 24), 3, 3);
        }
        int cx = size / 2;
        g.setColor(new Color(248, 250, 252));
        g.fillRoundRect(cx - 22, 58, 44, 90, 18, 18);
        g.setColor(new Color(239, 68, 68));
        g.fillPolygon(new int[]{cx - 22, cx, cx + 22}, new int[]{60, 18, 60}, 3);
        g.setColor(new Color(56, 189, 248));
        g.fillOval(cx - 10, 88, 20, 20);
        g.setColor(new Color(251, 146, 60));
        g.fillPolygon(new int[]{cx - 22, cx - 42, cx - 22}, new int[]{118, 148, 148}, 3);
        g.fillPolygon(new int[]{cx + 22, cx + 42, cx + 22}, new int[]{118, 148, 148}, 3);
        g.setColor(new Color(251, 191, 36));
        g.fillPolygon(new int[]{cx - 12, cx, cx + 12}, new int[]{148, 178, 148}, 3);
    }

    /** 帆船：帆在上、船体在下 */
    private static void paintRotateSailboat(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(125, 211, 252), new Color(186, 230, 253));
        g.setColor(new Color(14, 165, 233));
        g.fillRect(0, size - 56, size, 56);
        g.setColor(new Color(255, 255, 255, 120));
        g.fillOval(18, size - 48, 50, 18);
        g.fillOval(size - 70, size - 42, 40, 14);
        int cx = size / 2;
        g.setColor(new Color(120, 53, 15));
        g.fillRect(cx - 3, 48, 6, 86);
        g.setColor(new Color(254, 249, 195));
        g.fillPolygon(new int[]{cx + 3, cx + 58, cx + 3}, new int[]{52, 110, 110}, 3);
        g.setColor(new Color(254, 215, 170));
        g.fillPolygon(new int[]{cx - 3, cx - 48, cx - 3}, new int[]{70, 118, 118}, 3);
        g.setColor(new Color(180, 83, 9));
        g.fillPolygon(new int[]{cx - 56, cx - 40, cx + 40, cx + 56}, new int[]{142, 162, 162, 142}, 4);
        paintRotateSoftBubbles(g, size, random, 2);
    }

    /** 热气球：球在上、吊篮在下 */
    private static void paintRotateBalloon(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(224, 242, 254), new Color(125, 211, 252));
        int cx = size / 2;
        g.setColor(new Color(244, 114, 182));
        g.fillOval(cx - 48, 22, 96, 100);
        g.setColor(new Color(251, 113, 133));
        g.fillOval(cx - 34, 34, 68, 72);
        g.setColor(new Color(255, 255, 255, 90));
        g.fillOval(cx - 22, 40, 28, 36);
        g.setStroke(new BasicStroke(2.2f));
        g.setColor(new Color(120, 53, 15));
        g.drawLine(cx - 18, 118, cx - 16, 142);
        g.drawLine(cx + 18, 118, cx + 16, 142);
        g.setColor(new Color(180, 83, 9));
        g.fillRoundRect(cx - 20, 140, 40, 28, 6, 6);
        paintRotateSoftBubbles(g, size, random, 3);
    }

    /** 冰淇淋：球在上、蛋筒在下 */
    private static void paintRotateIceCream(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(254, 226, 226), new Color(254, 249, 195));
        int cx = size / 2;
        g.setColor(new Color(251, 113, 133));
        g.fillOval(cx - 40, 28, 80, 70);
        g.setColor(new Color(253, 186, 116));
        g.fillOval(cx - 28, 58, 56, 48);
        g.setColor(new Color(255, 255, 255));
        g.fillOval(cx - 8, 22, 18, 18);
        g.setColor(new Color(251, 191, 36));
        g.fillPolygon(new int[]{cx - 34, cx + 34, cx}, new int[]{100, 100, 178}, 3);
        g.setColor(new Color(245, 158, 11));
        g.setStroke(new BasicStroke(2f));
        g.drawLine(cx - 18, 118, cx + 10, 150);
        g.drawLine(cx + 16, 112, cx - 8, 156);
        paintRotateSoftBubbles(g, size, random, 2);
    }

    /** 雨伞：伞面在上、伞柄在下 */
    private static void paintRotateUmbrella(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(191, 219, 254), new Color(226, 232, 240));
        int cx = size / 2;
        g.setColor(new Color(59, 130, 246));
        g.fillArc(cx - 70, 36, 140, 100, 0, 180);
        g.setColor(new Color(96, 165, 250));
        g.fillArc(cx - 70, 48, 140, 80, 0, 180);
        g.setColor(new Color(255, 255, 255, 100));
        g.fillArc(cx - 50, 44, 40, 36, 20, 140);
        g.setColor(new Color(71, 85, 105));
        g.setStroke(new BasicStroke(5f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND));
        g.drawLine(cx, 86, cx, 158);
        g.drawArc(cx - 18, 148, 22, 22, 180, 180);
        // 雨点示意方向感
        g.setStroke(new BasicStroke(2.4f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND));
        g.setColor(new Color(14, 165, 233, 160));
        for (int i = 0; i < 6; i++) {
            int x = 28 + i * 28;
            g.drawLine(x, 150 + (i % 2) * 8, x - 4, 168 + (i % 2) * 8);
        }
        paintRotateSoftBubbles(g, size, random, 2);
    }

    /** 花朵：花冠在上、茎叶在下 */
    private static void paintRotateFlower(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(220, 252, 231), new Color(187, 247, 208));
        int cx = size / 2;
        Color[] petals = {
                new Color(244, 114, 182),
                new Color(251, 113, 133),
                new Color(192, 132, 252),
                new Color(248, 113, 113)
        };
        for (int i = 0; i < 6; i++) {
            double a = Math.toRadians(i * 60 - 90);
            int px = cx + (int) (28 * Math.cos(a));
            int py = 58 + (int) (28 * Math.sin(a));
            g.setColor(petals[i % petals.length]);
            g.fillOval(px - 18, py - 18, 36, 36);
        }
        g.setColor(new Color(253, 224, 71));
        g.fillOval(cx - 16, 42, 32, 32);
        g.setColor(new Color(22, 163, 74));
        g.setStroke(new BasicStroke(6f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND));
        g.drawLine(cx, 88, cx, 168);
        g.fillOval(cx + 6, 118, 34, 18);
        g.fillOval(cx - 40, 128, 34, 18);
        paintRotateSoftBubbles(g, size, random, 2);
    }

    /** 向上箭头：尖头朝上 */
    private static void paintRotateArrow(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(14, 165, 233), new Color(6, 182, 212));
        paintRotateSoftBubbles(g, size, random, 4);
        int cx = size / 2;
        g.setColor(new Color(255, 255, 255, 235));
        g.fillPolygon(new int[]{cx, cx - 48, cx + 48}, new int[]{28, 96, 96}, 3);
        g.fillRoundRect(cx - 22, 88, 44, 70, 12, 12);
        g.setColor(new Color(15, 23, 42));
        g.setFont(new Font("SansSerif", Font.BOLD, 14));
        g.drawString("UP", cx - 12, size - 28);
    }

    /** 灯塔：灯室在上、塔身在下 */
    private static void paintRotateLighthouse(Graphics2D g, int size, Random random) {
        fillRotateBg(g, size, new Color(30, 58, 138), new Color(56, 189, 248));
        g.setColor(new Color(253, 224, 71, 90));
        g.fillPolygon(new int[]{size / 2, size / 2 - 70, size / 2 + 70}, new int[]{70, 20, 20}, 3);
        int cx = size / 2;
        g.setColor(new Color(248, 250, 252));
        g.fillRect(cx - 18, 56, 36, 28);
        g.setColor(new Color(251, 191, 36));
        g.fillOval(cx - 10, 62, 20, 16);
        g.setColor(new Color(239, 68, 68));
        g.fillPolygon(new int[]{cx - 28, cx - 18, cx + 18, cx + 28}, new int[]{92, 56, 56, 92}, 4);
        // 红白条纹塔身
        for (int i = 0; i < 5; i++) {
            g.setColor(i % 2 == 0 ? new Color(248, 250, 252) : new Color(239, 68, 68));
            g.fillRect(cx - 24 + i, 92 + i * 14, 48 - i * 2, 14);
        }
        g.setColor(new Color(100, 116, 139));
        g.fillRect(0, size - 28, size, 28);
        paintRotateSoftBubbles(g, size, random, 2);
    }

    private static BufferedImage createAngleDial(int size, int angle, Random random) {
        BufferedImage img = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setColor(new Color(241, 245, 249));
        g.fillRect(0, 0, size, size);

        int cx = size / 2;
        int cy = size / 2;
        int outer = size / 2 - 12;
        g.setColor(new Color(226, 232, 240));
        g.fillOval(cx - outer, cy - outer, outer * 2, outer * 2);
        g.setColor(new Color(14, 165, 233));
        g.setStroke(new BasicStroke(3f));
        g.drawOval(cx - outer, cy - outer, outer * 2, outer * 2);

        // 刻度
        for (int i = 0; i < 12; i++) {
            double a = Math.toRadians(i * 30 - 90);
            int x1 = cx + (int) ((outer - 8) * Math.cos(a));
            int y1 = cy + (int) ((outer - 8) * Math.sin(a));
            int x2 = cx + (int) ((outer - (i % 3 == 0 ? 22 : 14)) * Math.cos(a));
            int y2 = cy + (int) ((outer - (i % 3 == 0 ? 22 : 14)) * Math.sin(a));
            g.setStroke(new BasicStroke(i % 3 == 0 ? 3f : 1.5f));
            g.setColor(i == 0 ? new Color(16, 185, 129) : new Color(100, 116, 139));
            g.drawLine(x1, y1, x2, y2);
        }
        // 正上方目标三角
        g.setColor(new Color(16, 185, 129));
        int[] txs = {cx, cx - 8, cx + 8};
        int[] tys = {8, 22, 22};
        g.fillPolygon(txs, tys, 3);

        // 指针（已偏转 angle）
        AffineTransform old = g.getTransform();
        g.rotate(Math.toRadians(angle), cx, cy);
        g.setStroke(new BasicStroke(5f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND));
        g.setColor(new Color(239, 68, 68));
        g.drawLine(cx, cy, cx, cy - outer + 28);
        g.setColor(new Color(15, 23, 42));
        g.fillOval(cx - 8, cy - 8, 16, 16);
        g.setTransform(old);
        g.dispose();
        return img;
    }

    private static BufferedImage rotateSquare(BufferedImage src, int angleDeg) {
        int size = src.getWidth();
        BufferedImage out = new BufferedImage(size, size, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = out.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.setColor(new Color(248, 250, 252));
        g.fillRect(0, 0, size, size);
        AffineTransform at = new AffineTransform();
        at.translate(size / 2.0, size / 2.0);
        at.rotate(Math.toRadians(angleDeg));
        at.translate(-size / 2.0, -size / 2.0);
        g.drawImage(src, at, null);
        g.dispose();
        return out;
    }

    private static void fillNoiseBackground(Graphics2D g, int w, int h) {
        g.setColor(new Color(238, 245, 250));
        g.fillRect(0, 0, w, h);
        Random random = RandomUtil.getRandom();
        for (int i = 0; i < 28; i++) {
            g.setColor(new Color(random.nextInt(160, 220), random.nextInt(170, 230), random.nextInt(180, 240)));
            g.fillOval(random.nextInt(w), random.nextInt(h), 3, 3);
        }
    }

    private static void drawInterference(Graphics2D g, int w, int h) {
        Random random = RandomUtil.getRandom();
        g.setStroke(new BasicStroke(1.2f));
        for (int i = 0; i < 4; i++) {
            g.setColor(new Color(random.nextInt(120, 180), random.nextInt(130, 190), random.nextInt(140, 200), 120));
            g.drawLine(random.nextInt(w), random.nextInt(h), random.nextInt(w), random.nextInt(h));
        }
    }

    private static String toBase64(BufferedImage image) {
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            ImageIO.write(image, "png", out);
            return "data:image/png;base64," + Base64.getEncoder().encodeToString(out.toByteArray());
        } catch (Exception e) {
            throw new IllegalStateException("生成验证码图片失败", e);
        }
    }

    private static String toBase64Png(BufferedImage image) {
        return toBase64(image);
    }

    public static int patternSlots() {
        return PATTERN_SLOTS;
    }
}
