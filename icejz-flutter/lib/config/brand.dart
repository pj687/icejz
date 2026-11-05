class BrandFeature {
  const BrandFeature(this.title, this.desc);
  final String title;
  final String desc;
}

class Brand {
  static const name = 'ICEJZ';
  static const fullName = 'ICEJZ 低代码开发平台';
  static const slogan = '更快交付 · 更稳运行 · 更易扩展';
  static const tagline = '低代码开发平台 · ICECORE 引擎';
  static const description =
      '面向企业的低代码开发平台，支持代码生成、在线表单、工作流与多端接入，帮助团队更快交付业务系统。';
  static const poweredBy = 'ICEJZ';
  static const footer = '© 2026 ICEJZ';
  static const version = 'v1.0.3';
  static const workspaceKicker = 'ICEJZ WORKSPACE';
  static const workspaceTitle = '工作台';
  static const workspaceSub = '与管理端同源数据，移动端快速查阅';
  static const homeLine = '代码生成 · 在线表单 · 工作流 · 多端接入';
  static const loginHint = '进入 ICEJZ 移动端';
  static const aboutIntro =
      'ICEJZ 是面向企业的低代码开发平台，基于 ICECORE 引擎提供代码生成、在线表单、工作流与多端接入能力，帮助团队更快交付业务系统。';

  static const features = <BrandFeature>[
    BrandFeature('安全可靠', '统一认证、细粒度权限与操作审计'),
    BrandFeature('快速开发', '代码生成与模块化能力加速交付'),
    BrandFeature('灵活扩展', '业务模块可插拔，适配多端场景'),
    BrandFeature('支持信创', '面向国产化环境持续适配'),
  ];
}
