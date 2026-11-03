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
            default -> fromEasy(newSpec(Captcha.TYPE_DEFAULT, 5), CaptchaTypeEnum.SPEC);
        };
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
            new PatternIcon("雨伞", new Color(219, 39, 119))
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
     * 风景风底图：多主题随机（晴空 / 暮色 / 雪岭 / 紫夜 / 秋林 / 沙漠 / 稻田 / 樱花粉 / 雨青 / 湖光）
     */
    private static void paintPuzzleBackground(Graphics2D g, Random random) {
        int theme = random.nextInt(10);
        Color skyTop;
        Color skyBottom;
        Color hillFar;
        Color hillNear;
        Color ground;
        Color accent;
        boolean night = false;
        boolean snow = false;
        boolean desert = false;
        boolean sakura = false;
        switch (theme) {
            case 0 -> { // 晴空山野
                skyTop = new Color(120, 190, 245);
                skyBottom = new Color(210, 235, 255);
                hillFar = new Color(90, 150, 120);
                hillNear = new Color(55, 120, 85);
                ground = new Color(72, 140, 78);
                accent = new Color(255, 220, 120);
            }
            case 1 -> { // 暮色海岸
                skyTop = new Color(255, 140, 90);
                skyBottom = new Color(255, 210, 160);
                hillFar = new Color(120, 90, 140);
                hillNear = new Color(70, 70, 110);
                ground = new Color(55, 95, 120);
                accent = new Color(255, 240, 200);
            }
            case 2 -> { // 雪岭冷色
                skyTop = new Color(70, 110, 160);
                skyBottom = new Color(190, 215, 240);
                hillFar = new Color(150, 170, 190);
                hillNear = new Color(110, 130, 155);
                ground = new Color(230, 236, 242);
                accent = new Color(255, 255, 255);
                snow = true;
            }
            case 3 -> { // 紫霞夜空
                skyTop = new Color(28, 24, 72);
                skyBottom = new Color(88, 56, 140);
                hillFar = new Color(52, 48, 96);
                hillNear = new Color(36, 40, 78);
                ground = new Color(24, 32, 58);
                accent = new Color(240, 230, 140);
                night = true;
            }
            case 4 -> { // 秋日枫林
                skyTop = new Color(255, 176, 96);
                skyBottom = new Color(255, 226, 170);
                hillFar = new Color(180, 100, 60);
                hillNear = new Color(150, 70, 40);
                ground = new Color(168, 110, 55);
                accent = new Color(255, 210, 80);
            }
            case 5 -> { // 沙漠黄昏
                skyTop = new Color(255, 170, 90);
                skyBottom = new Color(255, 220, 160);
                hillFar = new Color(210, 160, 100);
                hillNear = new Color(190, 140, 80);
                ground = new Color(220, 180, 110);
                accent = new Color(255, 230, 150);
                desert = true;
            }
            case 6 -> { // 青绿稻田
                skyTop = new Color(130, 200, 240);
                skyBottom = new Color(200, 235, 250);
                hillFar = new Color(100, 170, 110);
                hillNear = new Color(70, 150, 90);
                ground = new Color(120, 180, 70);
                accent = new Color(255, 230, 120);
            }
            case 7 -> { // 樱花粉春
                skyTop = new Color(180, 210, 245);
                skyBottom = new Color(255, 230, 240);
                hillFar = new Color(140, 170, 130);
                hillNear = new Color(100, 140, 100);
                ground = new Color(120, 160, 100);
                accent = new Color(255, 170, 190);
                sakura = true;
            }
            case 8 -> { // 雨后青灰
                skyTop = new Color(90, 120, 150);
                skyBottom = new Color(170, 195, 210);
                hillFar = new Color(80, 110, 100);
                hillNear = new Color(60, 90, 85);
                ground = new Color(70, 100, 90);
                accent = new Color(220, 230, 240);
            }
            default -> { // 湖光碧色
                skyTop = new Color(80, 170, 220);
                skyBottom = new Color(170, 220, 240);
                hillFar = new Color(60, 130, 150);
                hillNear = new Color(40, 110, 130);
                ground = new Color(50, 140, 160);
                accent = new Color(255, 245, 200);
            }
        }

        g.setPaint(new GradientPaint(0, 0, skyTop, 0, PUZZLE_H, skyBottom));
        g.fillRect(0, 0, PUZZLE_W, PUZZLE_H);

        // 太阳 / 月亮
        int orbX = random.nextInt(40, PUZZLE_W - 60);
        int orbY = random.nextInt(12, 42);
        int orbR = random.nextInt(14, 22);
        g.setColor(new Color(accent.getRed(), accent.getGreen(), accent.getBlue(), snow || night ? 200 : 230));
        g.fillOval(orbX, orbY, orbR * 2, orbR * 2);
        if (!snow && !night) {
            g.setColor(new Color(accent.getRed(), accent.getGreen(), accent.getBlue(), 60));
            g.fillOval(orbX - 6, orbY - 6, orbR * 2 + 12, orbR * 2 + 12);
        }

        // 夜空星点
        if (night) {
            for (int i = 0; i < 40; i++) {
                g.setColor(new Color(255, 255, 255, 120 + random.nextInt(100)));
                g.fillOval(random.nextInt(PUZZLE_W), random.nextInt(70), 2, 2);
            }
        }

        // 远山
        g.setColor(hillFar);
        GeneralPath far = new GeneralPath();
        far.moveTo(0, PUZZLE_H);
        far.lineTo(0, PUZZLE_H * 0.62);
        for (int x = 0; x <= PUZZLE_W; x += 28) {
            double h = PUZZLE_H * (0.38 + random.nextDouble() * 0.18);
            far.lineTo(x, h);
        }
        far.lineTo(PUZZLE_W, PUZZLE_H);
        far.closePath();
        g.fill(far);

        // 近山
        g.setColor(hillNear);
        GeneralPath near = new GeneralPath();
        near.moveTo(0, PUZZLE_H);
        near.lineTo(0, PUZZLE_H * 0.72);
        for (int x = 0; x <= PUZZLE_W; x += 22) {
            double h = PUZZLE_H * (0.52 + random.nextDouble() * 0.16);
            near.lineTo(x, h);
        }
        near.lineTo(PUZZLE_W, PUZZLE_H);
        near.closePath();
        g.fill(near);

        // 地面 / 水面波纹
        g.setColor(ground);
        g.fillRect(0, (int) (PUZZLE_H * 0.78), PUZZLE_W, PUZZLE_H);
        if (theme == 9) {
            g.setColor(new Color(255, 255, 255, 50));
            for (int i = 0; i < 5; i++) {
                int y = (int) (PUZZLE_H * 0.82) + i * 6;
                g.drawLine(10, y, PUZZLE_W - 10, y + random.nextInt(-2, 3));
            }
        }

        // 前景点缀：树 / 雪堆 / 仙人掌 / 枫树
        for (int i = 0; i < 7; i++) {
            int tx = random.nextInt(10, PUZZLE_W - 20);
            int ty = (int) (PUZZLE_H * 0.72) + random.nextInt(8, 22);
            if (snow) {
                g.setColor(new Color(170, 190, 210));
                g.fillOval(tx, ty, 14, 10);
            } else if (desert) {
                g.setColor(new Color(40, 120, 70));
                g.fillRect(tx + 5, ty - 8, 4, 16);
                g.fillOval(tx, ty - 6, 10, 6);
                g.fillOval(tx + 6, ty - 12, 10, 6);
            } else if (theme == 4) {
                g.setColor(new Color(190, 70, 40));
                GeneralPath tree = new GeneralPath();
                tree.moveTo(tx + 7, ty - 16);
                tree.lineTo(tx, ty + 4);
                tree.lineTo(tx + 14, ty + 4);
                tree.closePath();
                g.fill(tree);
                g.setColor(new Color(100, 60, 30));
                g.fillRect(tx + 5, ty + 2, 4, 8);
            } else {
                g.setColor(night ? new Color(20, 60, 40) : new Color(30, 90, 55));
                GeneralPath tree = new GeneralPath();
                tree.moveTo(tx + 7, ty - 16);
                tree.lineTo(tx, ty + 4);
                tree.lineTo(tx + 14, ty + 4);
                tree.closePath();
                g.fill(tree);
                g.setColor(new Color(90, 60, 40));
                g.fillRect(tx + 5, ty + 2, 4, 8);
            }
        }

        // 云朵 / 樱花瓣
        if (sakura) {
            for (int i = 0; i < 18; i++) {
                g.setColor(new Color(255, 160, 190, 140 + random.nextInt(80)));
                g.fillOval(random.nextInt(PUZZLE_W), random.nextInt(PUZZLE_H), 4, 3);
            }
        } else if (!night) {
            g.setColor(new Color(255, 255, 255, theme == 1 || theme == 5 ? 120 : 160));
            for (int i = 0; i < 3; i++) {
                int cx = random.nextInt(PUZZLE_W - 70);
                int cy = random.nextInt(8, 50);
                g.fillOval(cx, cy, 42, 16);
                g.fillOval(cx + 16, cy - 6, 30, 18);
                g.fillOval(cx + 28, cy + 2, 26, 14);
            }
        }

        // 雨丝（雨后青灰）
        if (theme == 8) {
            g.setColor(new Color(220, 230, 240, 90));
            g.setStroke(new BasicStroke(1f));
            for (int i = 0; i < 50; i++) {
                int x = random.nextInt(PUZZLE_W);
                int y = random.nextInt(PUZZLE_H - 20);
                g.drawLine(x, y, x - 2, y + 10);
            }
        }

        // 细微噪点，避免过于「矢量贴图」
        for (int i = 0; i < 180; i++) {
            g.setColor(new Color(255, 255, 255, 18 + random.nextInt(30)));
            g.fillRect(random.nextInt(PUZZLE_W), random.nextInt(PUZZLE_H), 1, 1);
        }
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
            case "单车", "小汽车", "大货车", "飞机", "帆船", "房子", "雨伞" -> true;
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
                // 伞面分段，轮廓更清晰，不易被认成叶子
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
            default -> new Ellipse2D.Double(cx - r, cy - r, r * 2.0, r * 2.0);
        };
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
