<template>
    <view class="usercenter-page">
        <view class="page-bg">
            <view class="bg-orb orb-left"></view>
            <view class="bg-orb orb-right"></view>
        </view>

        <view class="hero-card">
            <view class="hero-top">
                <view class="hero-profile">
                    <view class="avatar-wrap">
                        <image :src="displayAvatar" class="avatar" mode="aspectFill" />
                        <view v-if="isLoggedIn" class="avatar-online-dot"></view>
                    </view>
                    <view class="profile-meta">
                        <view class="name-row">
                            <text class="name">{{ displayName }}</text>
                        </view>
                        <text class="username-text" v-if="isLoggedIn && user.username">@{{ user.username }}</text>
                        <view v-if="isLoggedIn && roleTagList.length" class="role-tag-row">
                            <text v-for="role in roleTagList" :key="role.id" class="role-tag" :class="role.className">{{ role.label }}</text>
                        </view>
                    </view>
                </view>
                <view class="status-chip">{{ isLoggedIn ? '已登录' : '欢迎使用' }}</view>
            </view>


            <view class="hero-bottom">
                <view class="hero-score-card">
                    <text class="hero-score-label">健康评分</text>
                    <text class="hero-score-value">{{ overview.healthScore }}</text>
                    <text class="hero-score-tip">本周状态稳定</text>
                </view>
                <view class="hero-highlight">
                    <text class="highlight-title">今日提醒</text>
                    <text class="highlight-desc">{{ overview.todoCount }} 项待处理，建议优先查看预约与照护动态。</text>
                    <view class="highlight-tags">
                        <text class="tag" @tap="openTodoCenter">服务提醒</text>
                        <text class="tag soft" @tap="openTodoCenter">健康关注</text>
                    </view>
                </view>
            </view>
        </view>

        <view class="stats-row">
            <view class="stat-card light-card">
                <text class="stat-value">{{ overview.monthServiceCount }}</text>
                <text class="stat-label">本月服务</text>
                <text class="stat-foot">服务进行中</text>
            </view>
            <view class="stat-card light-card tappable-card" @tap="openTodoCenter">
                <text class="stat-value">{{ overview.todoCount }}</text>
                <text class="stat-label">待办提醒</text>
                <text class="stat-foot">点击查看待处理事项</text>
            </view>
            <view class="stat-card light-card accent-card tappable-card" @tap="openFamilyRelations">
                <text class="stat-value">{{ overview.familyCount }}</text>
                <text class="stat-label">关联家人</text>
                <text class="stat-foot">点击查看家人信息</text>
            </view>
        </view>

        <view class="section-card light-card quick-card">
            <view class="section-header">
                <view>
                    <text class="section-title">常用服务</text>
                    <text class="section-subtitle">{{ quickSectionSubtitle }}</text>
                </view>
                <text class="section-link" @tap="navigateTo('userinfo/userinfo')">查看资料</text>
            </view>
            <view class="quick-grid">
                <view
                    v-for="action in quickActions"
                    :key="action.key"
                    class="quick-item"
                    :class="{ 'quick-item-primary': action.primary, 'quick-item-dim': action.dim }"
                    @tap="action.handler"
                >
                    <view class="quick-icon" :class="action.iconClass">
                        <uni-icons :type="action.icon" size="24" color="#ffffff" />
                    </view>
                    <view class="quick-name-row">
                        <text class="quick-name">{{ action.name }}</text>
                        <view v-if="action.primary" class="quick-primary-badge">推荐</view>
                    </view>
                    <text class="quick-tip">{{ action.tip }}</text>
                </view>
            </view>
        </view>

        <view class="section-card light-card care-card">
            <view class="section-header compact-header">
                <view>
                    <text class="section-title">服务概览</text>
                    <text class="section-subtitle">最近服务与关怀进展</text>
                </view>
            </view>
            <view class="profile-panels" :class="{ 'profile-panels-single': !showElderArchivePanel || !showEmergencyPanel }">
                <!-- 老人角色：显示本人档案；家属角色：有绑定老人才显示 -->
                <view v-if="showElderArchivePanel" class="profile-panel warm-panel tappable-panel" :class="{ 'panel-full': !showEmergencyPanel }" @tap="openElderArchiveDetail">
                    <view class="panel-badge">{{ isElderRole ? '我的档案' : '老人档案' }}</view>
                    <text class="panel-main">{{ elderArchive ? (elderArchive.realName || '已建立档案') : '暂无档案' }}</text>
                    <text class="panel-sub">{{ elderArchive ? `健康状态：${elderArchive.healthStatus || '暂无记录'}` : (isElderRole ? '可前往完善个人健康档案' : '暂未关联老人档案') }}</text>
                    <view v-if="elderArchive" class="panel-detail-list">
                        <view class="detail-row">
                            <text class="detail-label">性别</text>
                            <text class="detail-value">{{ formatGender(elderArchive.gender) }}</text>
                        </view>
                        <view class="detail-row">
                            <text class="detail-label">联系电话</text>
                            <text class="detail-value">{{ elderArchive.mobile || '未填写' }}</text>
                        </view>
                        <view class="detail-row">
                            <text class="detail-label">{{ isElderRole ? '紧急联系人' : '紧急联系人' }}</text>
                            <text class="detail-value">{{ elderArchive.emergencyContactName || '未填写' }}</text>
                        </view>
                    </view>
                </view>
                <!-- 老人角色：显示紧急联系人；家属角色：显示绑定关系 -->
                <view v-if="showEmergencyPanel" class="profile-panel soft-panel" :class="{ 'panel-full': !showElderArchivePanel }">
                    <view class="panel-badge-row">
                        <view class="panel-badge">{{ isElderRole ? '紧急联系人' : '我的绑定' }}</view>
                        <view v-if="isElderRole" class="panel-add-btn" @tap="openAddEmergencyContact">
                            <uni-icons type="plusempty" size="16" color="#00a8e8" />
                            <text class="panel-add-text">添加</text>
                        </view>
                    </view>
                    <text class="panel-main">{{ familyBindings.length }} 位</text>
                    <text class="panel-sub">{{ familyBindings.length ? (isElderRole ? '已关联家属/紧急联系人' : '已绑定老人关联记录') : (isElderRole ? '暂未添加紧急联系人' : '暂未绑定老人') }}</text>
                    <view v-if="familyBindings.length" class="contact-list">
                        <view class="contact-chip" v-for="item in familyBindings.slice(0, 3)" :key="item.id || `${item.familyMemberUserId}-${item.elderMemberUserId}`" @tap="openContactAction(item)">
                            <view class="contact-main">
                                <text class="contact-name">{{ item.contactUserName || item.relationType || '联系人' }}</text>
                                <text class="contact-meta">{{ item.relationType || '关联关系' }} · {{ item.bindStatus === 1 ? '已绑定' : '待确认' }}</text>
                                <text class="contact-phone">{{ maskMobile(item.contactUserMobile) }}</text>
                            </view>
                            <uni-icons type="arrowright" size="16" color="#94a3b8" />
                        </view>
                    </view>
                    <view v-else-if="isElderRole" class="contact-empty" @tap="openAddEmergencyContact">
                        <uni-icons type="plusempty" size="28" color="#bfdbfe" />
                        <text class="contact-empty-text">点击添加紧急联系人</text>
                    </view>
                </view>
            </view>
            <view class="care-timeline">
                <view class="timeline-item" v-for="item in careTimeline" :key="item.title">
                    <view class="timeline-dot"></view>
                    <view class="timeline-content">
                        <view class="timeline-head">
                            <text class="timeline-title">{{ item.title }}</text>
                            <text class="timeline-time">{{ item.time }}</text>
                        </view>
                        <text class="timeline-desc">{{ item.desc }}</text>
                    </view>
                </view>
            </view>
        </view>

        <view class="section-card light-card service-card">
            <view class="section-header compact-header">
                <view>
                    <text class="section-title">服务与支持</text>
                    <text class="section-subtitle">社区养老与服务保障</text>
                </view>
            </view>
            <view class="list-item" @tap="navigateTo('about/about')">
                <view class="list-left">
                    <view class="list-icon list-icon-soft">
                        <uni-icons type="paperplane" size="18" color="#111827" />
                    </view>
                    <view>
                        <text class="item-title">系统介绍</text>
                        <text class="item-desc">查看平台能力、服务范围与使用说明</text>
                    </view>
                </view>
                <uni-icons type="arrowright" size="18" color="#9ca3af" />
            </view>
            <!-- <view class="list-item" @tap="openFeedbackDialog">
                <view class="list-left">
                    <view class="list-icon list-icon-soft cool">
                        <uni-icons type="chatboxes" size="18" color="#111827" />
                    </view>
                        <view>
                            <text class="item-title">意见反馈</text>
                            <text class="item-desc">提交使用建议，帮助持续优化服务体验</text>
                        </view>
                </view>
                <uni-icons type="arrowright" size="18" color="#9ca3af" />
            </view> -->
            <view class="list-item" @tap="openMakePhone">
                <view class="list-left">
                    <view class="list-icon list-icon-soft warm">
                        <uni-icons type="phone" size="18" color="#111827" />
                    </view>
                    <view>
                        <text class="item-title">客服热线</text>
                        <text class="item-desc">工作日 9:00 - 18:00 人工在线</text>
                    </view>
                </view>
                <uni-icons type="arrowright" size="18" color="#9ca3af" />
            </view>
        </view>

        <view class="action-wrap">
            <button v-if="isLoggedIn" class="action-btn logout" @click="onLogout">退出登录</button>
            <button v-else class="action-btn login" @click="onLogin">立即登录</button>
        </view>

        <view v-if="showContactDetail" class="popup-overlay detail-mask" @click="closeContactDetail">
            <view class="popup-content detail-popup" @click.stop>
                <view class="popup-header">
                    <text class="popup-header-title">联系人详情</text>
                    <view class="popup-close-btn" @tap="closeContactDetail">
                        <uni-icons type="closeempty" size="24" color="#999" />
                    </view>
                </view>
                <view class="detail-card">
                    <text class="detail-contact-name">{{ activeContact.contactUserName || '联系人' }}</text>
                    <text class="detail-contact-role">{{ activeContact.relationType || '家属关系' }}</text>
                </view>
                <view class="detail-info-list">
                    <view class="detail-info-row">
                        <text class="detail-info-label">手机号</text>
                        <text class="detail-info-value">{{ activeContact.contactUserMobile || '未填写' }}</text>
                    </view>
                    <view class="detail-info-row">
                        <text class="detail-info-label">绑定状态</text>
                        <text class="detail-info-value">{{ activeContact.bindStatus === 1 ? '已绑定' : '待确认' }}</text>
                    </view>
                    <view class="detail-info-row">
                        <text class="detail-info-label">审核状态</text>
                        <text class="detail-info-value">{{ activeContact.verifyStatus === 1 ? '已通过' : '待审核' }}</text>
                    </view>
                    <view class="detail-info-row">
                        <text class="detail-info-label">备注</text>
                        <text class="detail-info-value">{{ activeContact.remark || '暂无备注' }}</text>
                    </view>
                </view>
                <view class="detail-action-row detail-action-row-top">
                    <button class="detail-secondary-btn" @tap="editContactRemark">编辑备注</button>
                    <button class="detail-danger-btn" @tap="unbindActiveContact">解除绑定</button>
                </view>
                <view class="detail-action-row">
                    <button class="detail-secondary-btn" @tap="closeContactDetail">关闭</button>
                    <button class="detail-primary-btn" @tap="callActiveContact">拨打电话</button>
                </view>
            </view>
        </view>

        <view v-if="showAddContact" class="popup-overlay add-contact-mask" @click="closeAddContact">
            <view class="popup-content add-contact-popup" @click.stop>
                <view class="popup-header">
                    <text class="popup-header-title">添加紧急联系人</text>
                    <view class="popup-close-btn" @tap="closeAddContact">
                        <uni-icons type="closeempty" size="24" color="#999" />
                    </view>
                </view>
                <view class="add-contact-body">
                    <view class="add-contact-tip">
                        <uni-icons type="info" size="16" color="#00a8e8" />
                        <text class="add-contact-tip-text">输入家属手机号，获取对方短信验证码后即可直接建立绑定</text>
                    </view>
                    <view class="add-contact-field">
                        <text class="field-label">家属手机号</text>
                        <input
                            class="field-input"
                            type="number"
                            maxlength="11"
                            placeholder="请输入手机号"
                            v-model="addContactForm.mobile"
                        />
                    </view>
                    <view class="add-contact-field">
                        <text class="field-label">短信验证码</text>
                        <view class="code-row">
                            <input
                                class="field-input code-input"
                                type="number"
                                maxlength="6"
                                placeholder="请输入验证码"
                                v-model="addContactForm.verifyCode"
                            />
                            <button class="code-btn" :disabled="addContactSms.disabled || addContactCodeLoading" @tap="sendAddContactCode">
                                {{ addContactSms.disabled ? `${addContactSms.count}s后重发` : '获取验证码' }}
                            </button>
                        </view>
                    </view>
                    <view class="add-contact-field">
                        <text class="field-label">关系备注</text>
                        <input
                            class="field-input"
                            type="text"
                            maxlength="10"
                            placeholder="如：儿子、女儿、配偶"
                            v-model="addContactForm.relationType"
                        />
                    </view>
                </view>
                <view class="detail-action-row" style="padding-bottom: 24rpx;">
                    <button class="detail-secondary-btn" @tap="closeAddContact">取消</button>
                    <button class="detail-primary-btn" @tap="submitAddContact" :disabled="addContactLoading">
                        {{ addContactLoading ? '绑定中...' : '确认绑定' }}
                    </button>
                </view>
            </view>
        </view>

        <view v-if="showUnbindConfirm" class="popup-overlay unbind-mask" @click="showUnbindConfirm = false">
            <view class="popup-content unbind-popup" @click.stop>
                <view class="unbind-header">
                    <text class="unbind-title">解除绑定确认</text>
                    <text class="unbind-desc">确定要解除当前联系人绑定吗？解除后将无法继续同步关怀信息。</text>
                </view>
                <view class="detail-action-row unbind-actions">
                    <button class="detail-secondary-btn" @tap="showUnbindConfirm = false">取消</button>
                    <button class="detail-danger-btn" @tap="confirmUnbindActiveContact">确认解除</button>
                </view>
            </view>
        </view>

        <view v-if="showMakePhone" class="popup-overlay phone-mask" @click="closeMakePhone">
            <view class="popup-content" @click.stop>
                <view class="popup-header">
                    <text class="popup-header-title">联系客服</text>
                    <view class="popup-close-btn" @tap="closeMakePhone">
                        <uni-icons type="closeempty" size="24" color="#999" />
                    </view>
                </view>
                <view class="popup-time border-bottom-1px">
                    <uni-icons type="calendar" size="20" color="#666" />
                    <text class="popup-time-text">服务时间: 周一至周五 9:00-18:00</text>
                </view>
                <view class="popup-options">
                    <view class="popup-option border-bottom-1px" @tap="onPhoneCall">
                        <view class="option-left">
                            <uni-icons type="chatbubble" size="24" color="#07C160" />
                            <text class="option-title">QQ 联系</text>
                        </view>
                        <view class="option-right">
                            <text class="option-subtitle">960681673</text>
                            <uni-icons type="arrowright" size="16" color="#999" />
                        </view>
                    </view>
                    <view class="popup-option" @tap="onWechatService">
                        <view class="option-left">
                            <uni-icons type="email" size="24" color="#1AAD19" />
                            <text class="option-title">QQ 邮箱</text>
                        </view>
                        <view class="option-right">
                            <text class="option-subtitle">960681673@qq.com</text>
                            <uni-icons type="arrowright" size="16" color="#999" />
                        </view>
                    </view>
                </view>
                <view class="popup-cancel" @tap="closeMakePhone">取消</view>
            </view>
        </view>
    </view>
</template>

<script>
import cache from '../../utils/cache.js';
import { useLogoutApi } from '../../api/auth.js';
import { useUserInfoApi, useUserMemberSummaryApi, useFamilyBindingRemarkApi, useFamilyBindingUnbindApi, useFamilyBindingInviteApi, useFamilyInviteSendCodeApi, useNoticePageApi, useNoticeReadApi } from '../../api/user.js';

const DISMISSED_TODO_KEY = 'usercenterDismissedTodos';

export default {
    name: 'UserCenter',
    data() {
        return {
            showMakePhone: false,
            showContactDetail: false,
            showAddContact: false,
            showUnbindConfirm: false,
            addContactLoading: false,
            addContactCodeLoading: false,
            addContactSms: { disabled: false, count: 0, timer: null },
            addContactForm: { mobile: '', relationType: '', verifyCode: '' },
            activeContact: {},
            isLoggedIn: false,
            user: {
                avatar: '/static/logo.png',
                realName: ''
            },
            overview: {
                monthServiceCount: 0,
                todoCount: 0,
                healthScore: '--',
                familyCount: 0
            },
            elderArchive: null,
            familyBindings: [],
            noticeList: [],
            careTimeline: [
                { title: '上门照护已预约', time: '今天 14:00', desc: '本周照护服务已安排，护理人员会提前联系确认。' },
                { title: '健康档案已更新', time: '昨天', desc: '血压、睡眠与活动记录已同步，建议持续关注。' },
                { title: '家人提醒已发送', time: '周一', desc: '系统已向家属发送本周服务摘要与注意事项。' }
            ]
        };
    },
    computed: {
        displayName() {
            return this.user?.realName || '未登录用户';
        },
        displayAvatar() {
            return this.user?.avatar || '/static/logo.png';
        },
        roleTagList() {
            const roleIdList = Array.isArray(this.user?.roleIdList) ? this.user.roleIdList : [];
            const roleMap = {
                302: { id: 302, label: '家属', className: 'role-tag-family' },
                303: { id: 303, label: '老人', className: 'role-tag-elder' }
            };
            const roles = roleIdList
                .map(id => roleMap[id])
                .filter(Boolean);
            if (roles.length) {
                return roles;
            }
            return this.isLoggedIn ? [{ id: 'logged', label: '已登录用户', className: 'role-tag-default' }] : [];
        },
        isElderRole() {
            return this.roleTagList.some(item => item.id === 303);
        },
        isFamilyRole() {
            return this.roleTagList.some(item => item.id === 302);
        },
        heroSubtitle() {
            if (!this.isLoggedIn) {
                return '未登录 · 登录后查看完整照护服务与家人档案';
            }
            if (this.isElderRole) {
                return '已登录 · 关注健康服务、预约进度与照护提醒';
            }
            if (this.isFamilyRole) {
                return '已登录 · 查看老人档案、联系人关系与服务动态';
            }
            return '已登录 · 档案信息持续更新中';
        },
        quickSectionSubtitle() {
            if (this.isElderRole) return '为您优先展示健康与预约功能';
            if (this.isFamilyRole) return '为您优先展示档案与联系人管理';
            return '快捷进入高频功能';
        },
        quickActions() {
            const all = {
                userinfo: {
                    key: 'userinfo', name: '个人信息', tip: '查看与编辑基础资料',
                    icon: 'person', iconClass: 'quick-icon-dark',
                    handler: () => this.navigateTo('userinfo/userinfo')
                },
                password: {
                    key: 'password', name: '修改密码', tip: '提升账号安全等级',
                    icon: 'locked', iconClass: 'quick-icon-blue',
                    handler: () => this.navigateTo('password/password')
                },
                booking: {
                    key: 'booking', name: '我的预约', tip: '查看个人预约与服务安排',
                    icon: 'calendar', iconClass: 'quick-icon-green',
                    handler: () => this.openMyBookings()
                },
                health: {
                    key: 'health', name: '健康监测', tip: '查看健康数据与日常记录',
                    icon: 'heart', iconClass: 'quick-icon-orange',
                    handler: () => uni.navigateTo({ url: '/pages/services/health-monitor/health-monitor' })
                },
                elderArchive: {
                    key: 'elderArchive', name: '老人档案', tip: '查看长者基础信息与状态',
                    icon: 'contact', iconClass: 'quick-icon-orange',
                    handler: () => this.openElderArchiveDetail()
                },
                emergency: {
                    key: 'emergency', name: '紧急联系人', tip: '维护家属与紧急联系关系',
                    icon: 'staff', iconClass: 'quick-icon-rose',
                    handler: () => this.openEmergencyContacts()
                },
                phone: {
                    key: 'phone', name: '联系客服', tip: '快速获取平台帮助',
                    icon: 'phone', iconClass: 'quick-icon-violet',
                    handler: () => this.openMakePhone()
                }
            };

            // 老人：突出预约、健康监测；紧急联系人仅作参考弱化显示
            if (this.isElderRole) {
                return [
                    { ...all.booking, primary: true },
                    { ...all.health, primary: true },
                    { ...all.userinfo },
                    { ...all.password },
                    { ...all.emergency, dim: true, tip: '查看家属联系方式' },
                    { ...all.phone }
                ];
            }

            // 家属：突出老人档案、紧急联系人；弱化健康监测（家属不直接使用）
            return [
                { ...all.elderArchive, primary: true },
                { ...all.emergency, primary: true },
                { ...all.booking, tip: '查看老人服务预约与处理进度' },
                { ...all.userinfo },
                { ...all.password },
                { ...all.phone }
            ];
        },
        roleBookingTip() {
            return this.isElderRole ? '查看个人预约与服务安排' : '查看老人服务预约与处理进度';
        },
        // 老人角色：始终显示档案卡（自己的）；家属角色：有绑定老人才显示
        showElderArchivePanel() {
            if (this.isElderRole) return true;
            if (this.isFamilyRole) return !!this.elderArchive;
            return false;
        },
        // 老人角色：显示紧急联系人；家属角色：始终显示绑定关系卡
        showEmergencyPanel() {
            if (this.isElderRole) return true;
            if (this.isFamilyRole) return true;
            return false;
        }
    },
    async onShow() {
        this.user = cache.getUserInfo() || {};
        this.checkLoginStatus();
        await this.loadUserInfo();
        await this.loadMemberSummary();
    },
    methods: {
        checkLoginStatus() {
            const token = cache.getToken();
            const userInfo = cache.getUserInfo();
            this.isLoggedIn = !!token;
            if (!this.isLoggedIn) {
                this.user = {
                    avatar: '/static/logo.png',
                    realName: '未登录用户'
                };
                this.overview = {
                    monthServiceCount: 0,
                    todoCount: 0,
                    healthScore: '--',
                    familyCount: 0
                };
                return;
            }

            if (userInfo) {
                this.user = {
                    ...userInfo,
                    avatar: userInfo.avatar || '/static/logo.png'
                };
            }
        },
        async loadUserInfo() {
            if (!this.isLoggedIn) return;
            try {
                const response = await useUserInfoApi();
                if (!(response && response.code === 0 && response.data)) return;

                const userInfo = response.data;
                this.user = {
                    ...userInfo,
                    avatar: userInfo.avatar || '/static/logo.png'
                };
                cache.setUserInfo(this.user);

                const roleIdList = Array.isArray(userInfo.roleIdList) ? userInfo.roleIdList : [];
                const isElder = roleIdList.includes(303);
                const isFamily = roleIdList.includes(302);

                this.overview = {
                    monthServiceCount: Array.isArray(userInfo.postNameList) ? userInfo.postNameList.length : 0,
                    todoCount: userInfo.status === 1 ? 1 : 0,
                    healthScore: this.getHealthScore(userInfo),
                    familyCount: isFamily ? this.overview.familyCount : 0
                };
                this.careTimeline = this.buildCareTimeline(userInfo);

                if (isElder && !isFamily) {
                    this.overview.todoCount = Math.max(this.overview.todoCount, 1);
                }
            } catch (error) {
                console.error('loadUserInfo error', error);
            }
        },
        async loadMemberSummary() {
            if (!this.isLoggedIn) return;
            try {
                const response = await useUserMemberSummaryApi();
                if (!(response && response.code === 0 && response.data)) return;

                const summary = response.data || {};
                const roleIdList = Array.isArray(this.user?.roleIdList) ? this.user.roleIdList : [];
                const isElder = roleIdList.includes(303);
                const isFamily = roleIdList.includes(302);

                // 老人：自己的档案 + familyBindings 里是绑定的家属信息
                // 家属：elderArchives 里是绑定的老人档案，familyBindings 里是绑定关系
                if (isElder) {
                    this.elderArchive = summary.elderArchive || null;
                    // 老人的 familyBindings 里 contactUserName/contactUserMobile 已是家属信息
                    this.familyBindings = Array.isArray(summary.familyBindings) ? summary.familyBindings : [];
                } else if (isFamily) {
                    // 家属看绑定的老人档案（取第一个，或全部）
                    const elderArchives = Array.isArray(summary.elderArchives) ? summary.elderArchives : [];
                    this.elderArchive = elderArchives.length > 0 ? elderArchives[0] : null;
                    this.familyBindings = Array.isArray(summary.familyBindings) ? summary.familyBindings : [];
                } else {
                    this.elderArchive = summary.elderArchive || null;
                    this.familyBindings = Array.isArray(summary.familyBindings) ? summary.familyBindings : [];
                }

                this.overview.familyCount = isFamily
                    ? Number(summary.familyBindingCount || 0)
                    : this.familyBindings.length;
                await this.loadNoticeList();
                this.careTimeline = this.buildCareTimeline(this.user, this.elderArchive, this.familyBindings);
            } catch (error) {
                console.error('loadMemberSummary error', error);
            }
        },
        getHealthScore(userInfo) {
            if (!userInfo) return '--';
            const base = 88;
            const hasOrg = userInfo.orgId ? 4 : 0;
            const hasMobile = userInfo.mobile ? 3 : 0;
            const hasPosts = Array.isArray(userInfo.postNameList) ? Math.min(userInfo.postNameList.length, 3) : 0;
            return Math.min(base + hasOrg + hasMobile + hasPosts, 99);
        },
        formatGender(gender) {
            if (gender === 0) return '男';
            if (gender === 1) return '女';
            return '未知';
        },
        formatDate(dateStr) {
            if (!dateStr) return '未知';
            return String(dateStr).slice(0, 10);
        },
        maskMobile(mobile) {
            if (!mobile || String(mobile).length < 7) return mobile || '未填写';
            return String(mobile).replace(/(\d{3})\d{4}(\d+)/, '$1****$2');
        },
        openContactAction(item) {
            const phone = item?.contactUserMobile;
            this.activeContact = item || {};
            uni.showActionSheet({
                itemList: phone ? ['拨打电话', '查看详情'] : ['查看详情'],
                success: (res) => {
                    if (phone && res.tapIndex === 0) {
                        uni.makePhoneCall({ phoneNumber: phone });
                        return;
                    }
                    this.showContactDetail = true;
                }
            });
        },
        closeContactDetail() {
            this.showContactDetail = false;
            this.activeContact = {};
        },
        openElderArchiveDetail() {
            if (!this.isLoggedIn) {
                this.onLogin();
                return;
            }
            if (this.isElderRole) {
                uni.navigateTo({ url: '/pages/usercenter/elder-archive/list?mode=self' });
                return;
            }
            uni.navigateTo({ url: '/pages/usercenter/elder-archive/list' });
        },
        showElderArchiveDetail(item) {
            const detailLines = [
                `姓名：${item.realName || '未填写'}`,
                `性别：${this.formatGender(item.gender)}`,
                `手机号：${item.mobile || '未填写'}`,
                `健康状态：${item.healthStatus || '暂无记录'}`,
                `慢病情况：${item.chronicDisease || '暂无记录'}`,
                `过敏史：${item.allergyHistory || '暂无记录'}`,
                `紧急联系人：${item.emergencyContactName || '未填写'}`,
                `紧急联系人关系：${item.emergencyContactRelation || '未填写'}`,
                `紧急联系人电话：${item.emergencyContactMobile || '未填写'}`,
                `住址：${[item.province, item.city, item.district, item.address].filter(Boolean).join('') || '未填写'}`,
                `备注：${item.remark || '暂无备注'}`
            ];
            uni.showModal({
                title: '我的健康档案',
                content: detailLines.join('\n'),
                showCancel: false
            });
        },
        openFamilyRelations() {
            if (!this.isLoggedIn) {
                this.onLogin();
                return;
            }
            if (!this.familyBindings.length) {
                uni.showToast({ title: this.isElderRole ? '暂无关联家人' : '暂无绑定关系', icon: 'none' });
                return;
            }
            this.openEmergencyContacts();
        },
        openEmergencyContacts() {
            if (!this.isLoggedIn) {
                this.onLogin();
                return;
            }
            if (!this.familyBindings.length) {
                if (this.isElderRole) {
                    this.openAddEmergencyContact();
                    return;
                }
                uni.showToast({ title: '暂无紧急联系人', icon: 'none' });
                return;
            }
            if (this.familyBindings.length === 1) {
                this.activeContact = this.familyBindings[0];
                this.showContactDetail = true;
                return;
            }
            uni.showActionSheet({
                itemList: this.familyBindings.map(item => `${item.contactUserName || item.relationType || '联系人'} ${this.maskMobile(item.contactUserMobile)}`),
                success: ({ tapIndex }) => {
                    this.activeContact = this.familyBindings[tapIndex] || {};
                    if (this.activeContact.id || this.activeContact.contactUserName) {
                        this.showContactDetail = true;
                    }
                }
            });
        },
        openAddEmergencyContact() {
            if (!this.isLoggedIn) { this.onLogin(); return; }
            this.addContactForm = { mobile: '', relationType: '', verifyCode: '' };
            this.showAddContact = true;
        },
        closeAddContact() {
            this.showAddContact = false;
        },
        startAddContactCountdown() {
            if (this.addContactSms.timer) clearInterval(this.addContactSms.timer);
            this.addContactSms.count = 60;
            this.addContactSms.disabled = true;
            this.addContactSms.timer = setInterval(() => {
                if (this.addContactSms.count > 1) {
                    this.addContactSms.count -= 1;
                } else {
                    this.addContactSms.disabled = false;
                    clearInterval(this.addContactSms.timer);
                    this.addContactSms.timer = null;
                }
            }, 1000);
        },
        async sendAddContactCode() {
            const mobile = (this.addContactForm.mobile || '').trim();
            if (!/^1\d{10}$/.test(mobile)) {
                uni.showToast({ title: '请输入正确的手机号', icon: 'none' });
                return;
            }
            this.addContactCodeLoading = true;
            try {
                await useFamilyInviteSendCodeApi({ mobile });
                uni.showToast({ title: '验证码已发送，请查看控制台或短信', icon: 'none' });
                this.startAddContactCountdown();
            } catch (e) {
                uni.showToast({ title: e?.msg || '验证码发送失败', icon: 'none' });
            } finally {
                this.addContactCodeLoading = false;
            }
        },
        async submitAddContact() {
            const mobile = (this.addContactForm.mobile || '').trim();
            if (!/^1\d{10}$/.test(mobile)) {
                uni.showToast({ title: '请输入正确的手机号', icon: 'none' });
                return;
            }
            const verifyCode = (this.addContactForm.verifyCode || '').trim();
            if (!verifyCode) {
                uni.showToast({ title: '请输入验证码', icon: 'none' });
                return;
            }
            this.addContactLoading = true;
            try {
                await useFamilyBindingInviteApi({
                    mobile,
                    verifyCode,
                    relationType: this.addContactForm.relationType || ''
                });
                this.closeAddContact();
                uni.showToast({ title: '绑定成功', icon: 'success', duration: 2000 });
                await this.loadMemberSummary();
            } catch (e) {
                uni.showToast({ title: '发送失败，请稍后重试', icon: 'none' });
            } finally {
                this.addContactLoading = false;
            }
        },
        openRolePrimaryAction() {
            if (this.isElderRole) {
                uni.navigateTo({ url: '/pages/services/health-monitor/health-monitor' });
                return;
            }
            this.openElderArchiveDetail();
        },
        openRoleSecondaryAction() {
            this.openEmergencyContacts();
        },
        async loadNoticeList() {
            try {
                const response = await useNoticePageApi({ page: 1, limit: 20, readStatus: 0 });
                this.noticeList = response?.data?.list || [];
                this.overview.todoCount = Number(response?.data?.total || this.noticeList.length || 0);
            } catch (error) {
                console.error('load notice list error', error);
                this.noticeList = [];
                this.overview.todoCount = 0;
            }
        },
        buildTodoActions() {
            const todos = [];
            const archive = this.elderArchive || {};
            if (!this.elderArchive) {
                todos.push({
                    key: 'archive-create',
                    title: this.isElderRole ? '建立老人健康档案' : '绑定老人档案',
                    route: this.isElderRole ? '/pages/usercenter/elder-archive/list?mode=self' : '/pages/usercenter/elder-archive/list'
                });
            } else {
                const needImproveArchive =
                    !archive.birthday ||
                    !archive.address ||
                    !archive.emergencyContactName ||
                    !archive.emergencyContactMobile ||
                    !archive.chronicDisease ||
                    archive.healthStatus === '待完善';
                if (needImproveArchive) {
                    todos.push({ key: 'archive-improve', title: '完善老人健康档案', route: this.isElderRole ? '/pages/usercenter/elder-archive/list?mode=self' : '/pages/usercenter/elder-archive/list' });
                }
            }

            if (this.isElderRole) {
                todos.push({ key: 'order-review', title: '查看已完成服务并评价护工', route: '/pages/usercenter/order-list/order-list' });
            }

            const pendingBindingCount = this.familyBindings.filter(item => item.bindStatus !== 1 || item.verifyStatus !== 1).length;
            if (pendingBindingCount > 0) {
                todos.push({ key: 'binding-pending', title: `处理 ${pendingBindingCount} 条待确认绑定`, action: 'emergency' });
            } else if (this.familyBindings.length > 0) {
                todos.push({ key: 'binding-view', title: `查看 ${this.familyBindings.length} 位紧急联系人`, action: 'emergency' });
            } else if (this.isElderRole) {
                todos.push({ key: 'binding-add', title: '添加紧急联系人', action: 'addEmergency' });
            }

            return todos;
        },
        openTodoCenter() {
            if (!this.isLoggedIn) {
                this.onLogin();
                return;
            }
            const notices = this.noticeList;
            if (!notices.length) {
                uni.showToast({ title: '暂无待办事项', icon: 'none' });
                return;
            }
            uni.showActionSheet({
                itemList: notices.map(item => item.title),
                success: async ({ tapIndex }) => {
                    const target = notices[tapIndex];
                    if (!target) return;
                    await useNoticeReadApi(target.id);
                    await this.loadNoticeList();
                    if (target.routeUrl) {
                        uni.navigateTo({ url: target.routeUrl });
                        return;
                    }
                    uni.showModal({ title: target.title, content: target.content || '消息已读', showCancel: false });
                }
            });
        },
        openMyBookings() {
            if (!this.isLoggedIn) {
                this.onLogin();
                return;
            }
            uni.showActionSheet({
                itemList: ['上门照护预约', '康复理疗课程', '社区活动报名'],
                success: ({ tapIndex }) => {
                    const routes = [
                        '/pages/usercenter/order-list/order-list',
                        '/pages/services/rehab/rehab',
                        '/pages/activity/activity'
                    ];
                    uni.navigateTo({ url: routes[tapIndex] });
                }
            });
        },
        openFeedbackDialog() {
            if (!this.isLoggedIn) {
                this.onLogin();
                return;
            }
            uni.showModal({
                title: '意见反馈',
                editable: true,
                placeholderText: '请输入您的建议或遇到的问题',
                success: (res) => {
                    if (!res.confirm) return;
                    const content = (res.content || '').trim();
                    if (!content) {
                        uni.showToast({ title: '请输入反馈内容', icon: 'none' });
                        return;
                    }
                    uni.showToast({ title: '反馈已提交', icon: 'success' });
                }
            });
        },
        callActiveContact() {
            if (!this.activeContact?.contactUserMobile) {
                uni.showToast({ title: '联系人暂无手机号', icon: 'none' });
                return;
            }
            uni.makePhoneCall({ phoneNumber: this.activeContact.contactUserMobile });
        },
        editContactRemark() {
            if (!this.activeContact?.id) {
                uni.showToast({ title: '未找到联系人记录', icon: 'none' });
                return;
            }
            uni.showModal({
                title: '编辑备注',
                editable: true,
                placeholderText: '请输入备注信息',
                content: this.activeContact.remark || '',
                success: async (res) => {
                    if (!res.confirm) return;
                    try {
                        await useFamilyBindingRemarkApi({
                            id: this.activeContact.id,
                            remark: res.content || ''
                        });
                        this.activeContact.remark = res.content || '';
                        const target = this.familyBindings.find(item => item.id === this.activeContact.id);
                        if (target) target.remark = res.content || '';
                        uni.showToast({ title: '备注已更新', icon: 'success' });
                    } catch (error) {
                        console.error('editContactRemark error', error);
                    }
                }
            });
        },
        unbindActiveContact() {
            if (!this.activeContact?.elderMemberUserId || !this.activeContact?.familyMemberUserId) {
                uni.showToast({ title: '未找到绑定关系', icon: 'none' });
                return;
            }
            this.showUnbindConfirm = true;
        },
        async confirmUnbindActiveContact() {
            try {
                await useFamilyBindingUnbindApi({
                    elderMemberUserId: this.activeContact.elderMemberUserId,
                    familyMemberUserId: this.activeContact.familyMemberUserId
                });
                this.familyBindings = this.familyBindings.filter(item => item.id !== this.activeContact.id);
                this.overview.familyCount = this.familyBindings.length;
                this.showUnbindConfirm = false;
                this.closeContactDetail();
                uni.showToast({ title: '已解除绑定', icon: 'success' });
            } catch (error) {
                console.error('unbindActiveContact error', error);
            }
        },
        buildCareTimeline(userInfo, elderArchive = null, familyBindings = []) {
            return [
                {
                    title: '基础资料已同步',
                    time: userInfo.createTime || '刚刚',
                    desc: `当前登录账号为${userInfo.realName || '用户'}，手机号 ${userInfo.mobile || '未填写'}。`
                },
                {
                    title: elderArchive ? '老人档案已建立' : '老人档案待完善',
                    time: elderArchive ? '已同步' : '待完善',
                    desc: elderArchive
                        ? `当前档案姓名：${elderArchive.realName || '未填写'}，健康状态：${elderArchive.healthStatus || '暂无记录'}。`
                        : '当前账号下暂无老人档案，请后续补充长者资料。'
                },
                {
                    title: familyBindings.length ? '紧急联系人已关联' : '紧急联系人待完善',
                    time: familyBindings.length ? `共 ${familyBindings.length} 条` : '待完善',
                    desc: familyBindings.length
                        ? `已存在 ${familyBindings.length} 条家属/联系人绑定记录，可继续维护关系信息。`
                        : '当前暂无紧急联系人绑定信息。'
                }
            ];
        },
        navigateTo(url) {
            const targetUrl = url.startsWith('/') ? url : `/pages/usercenter/${url}`;
            uni.navigateTo({ url: targetUrl });
        },
        openMakePhone() {
            this.showMakePhone = true;
        },
        closeMakePhone() {
            this.showMakePhone = false;
        },
        onPhoneCall() {
            uni.setClipboardData({
                data: '960681673',
                success: () => uni.showToast({ title: 'QQ已复制：960681673', icon: 'none' })
            });
        },
        onWechatService() {
            uni.setClipboardData({
                data: '960681673@qq.com',
                success: () => uni.showToast({ title: '邮箱已复制', icon: 'none' })
            });
            this.closeMakePhone();
        },
        onLogin() {
            uni.navigateTo({ url: '/pages/login/login' });
        },
        onLogout() {
            uni.showModal({
                title: '提示',
                content: '确定要退出登录吗？',
                success: (res) => {
                    if (!res.confirm) return;
                    useLogoutApi()
                        .finally(() => {
                            cache.removeToken();
                            cache.removeUserInfo();
                            this.checkLoginStatus();
                            uni.showToast({ title: '已退出登录', icon: 'success' });
                        });
                }
            });
        }
    },
    onUnload() {
        if (this.addContactSms.timer) {
            clearInterval(this.addContactSms.timer);
            this.addContactSms.timer = null;
        }
    }
};
</script>

<style scoped>
.usercenter-page {
    min-height: 100vh;
    background:
      radial-gradient(circle at top left, rgba(0, 168, 232, 0.22) 0%, transparent 42%),
      linear-gradient(180deg, #121a28 0%, #162033 28%, #f4f7fb 28%);
    padding: 28rpx 24rpx 48rpx;
    position: relative;
    overflow: hidden;
}

.page-bg {
    position: absolute;
    inset: 0;
    pointer-events: none;
}

.bg-orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(90rpx);
    opacity: 0.18;
}

.orb-left {
    width: 300rpx;
    height: 300rpx;
    background: #00a8e8;
    top: 140rpx;
    left: -80rpx;
}

.orb-right {
    width: 360rpx;
    height: 360rpx;
    background: #3ec6ff;
    right: -120rpx;
    top: 280rpx;
}

.hero-card,
.section-card,
.stat-card,
.action-wrap {
    position: relative;
    z-index: 1;
}

.light-card {
    background: rgba(255, 255, 255, 0.92);
    border: 1rpx solid rgba(255, 255, 255, 0.5);
    box-shadow: 0 18rpx 42rpx rgba(0, 0, 0, 0.18);
    backdrop-filter: blur(18rpx);
    -webkit-backdrop-filter: blur(18rpx);
}

.hero-card {
    border-radius: 30rpx;
    padding: 32rpx;
    background:
      radial-gradient(circle at 92% 8%, rgba(62, 198, 255, 0.28), transparent 34%),
      linear-gradient(135deg, rgba(18, 26, 40, 0.96) 0%, rgba(20, 48, 71, 0.9) 100%);
    border: 1rpx solid rgba(0, 168, 232, 0.22);
    box-shadow: 0 24rpx 56rpx rgba(15, 23, 36, 0.28);
}

.hero-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.hero-profile {
    display: flex;
    align-items: center;
    flex: 1;
    min-width: 0;
}

.avatar {
    width: 104rpx;
    height: 104rpx;
    border-radius: 52rpx;
    margin-right: 20rpx;
    border: 4rpx solid rgba(255, 255, 255, 0.72);
    background: rgba(255, 255, 255, 0.12);
}

.profile-meta {
    flex: 1;
    min-width: 0;
}

.role-tag-row {
    margin-top: 14rpx;
    display: flex;
    flex-wrap: wrap;
    gap: 10rpx;
}

.role-tag {
    display: inline-block;
    padding: 6rpx 16rpx;
    border-radius: 999rpx;
    font-size: 20rpx;
    font-weight: 600;
}

.role-tag-elder {
    background: rgba(251, 191, 36, 0.2);
    color: #fcd34d;
}

.role-tag-family {
    background: rgba(79, 140, 255, 0.2);
    color: #7db7ff;
}

.role-tag-default {
    background: rgba(255, 255, 255, 0.12);
    color: #d1d5db;
}

.avatar-wrap {
    position: relative;
    margin-right: 20rpx;
    flex-shrink: 0;
}

.avatar-online-dot {
    position: absolute;
    bottom: 4rpx;
    right: 4rpx;
    width: 20rpx;
    height: 20rpx;
    border-radius: 50%;
    background: #22c55e;
    border: 3rpx solid #1a1a1a;
}

.name-row {
    color: #ffffff;
    display: flex;
    align-items: center;
    font-size: 36rpx;
    font-weight: 700;
    gap: 12rpx;
}

.gender-badge {
    font-size: 24rpx;
    padding: 2rpx 10rpx;
    border-radius: 999rpx;
    font-weight: 600;
}

.gender-male {
    background: rgba(79, 140, 255, 0.2);
    color: #7db7ff;
}

.gender-female {
    background: rgba(236, 72, 153, 0.2);
    color: #f9a8d4;
}

.username-text {
    display: block;
    margin-top: 6rpx;
    color: #9ca3af;
    font-size: 22rpx;
}

.info-grid {
    margin-top: 24rpx;
    padding-top: 22rpx;
    border-top: 1rpx solid rgba(255, 255, 255, 0.1);
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16rpx;
}

.info-item {
    display: flex;
    align-items: flex-start;
    gap: 12rpx;
    padding: 16rpx;
    border-radius: 16rpx;
    background: rgba(255, 255, 255, 0.06);
}

.info-icon {
    font-size: 28rpx;
    line-height: 1;
    margin-top: 2rpx;
}

.info-content {
    flex: 1;
    min-width: 0;
}

.info-label {
    display: block;
    color: #9ca3af;
    font-size: 20rpx;
}

.info-value {
    display: block;
    margin-top: 6rpx;
    color: #f3f4f6;
    font-size: 22rpx;
    font-weight: 500;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.name {
    display: block;
    color: #ffffff;
    font-size: 36rpx;
    font-weight: 700;
}

.sub {
    display: block;
    margin-top: 8rpx;
    color: #d1d5db;
    font-size: 22rpx;
    line-height: 1.6;
}

.status-chip {
    margin-left: 16rpx;
    padding: 12rpx 18rpx;
    border-radius: 999rpx;
    background: rgba(255, 255, 255, 0.14);
    color: #f9fafb;
    font-size: 22rpx;
    white-space: nowrap;
}

.hero-bottom {
    margin-top: 28rpx;
    display: grid;
    grid-template-columns: 220rpx 1fr;
    gap: 18rpx;
}

.hero-score-card {
    border-radius: 22rpx;
    padding: 24rpx 20rpx;
    background: linear-gradient(180deg, #fff6ea 0%, #fff2df 100%);
    color: #111827;
}

.hero-score-label {
    display: block;
    font-size: 22rpx;
    color: #7c5a28;
}

.hero-score-value {
    display: block;
    margin-top: 10rpx;
    font-size: 54rpx;
    font-weight: 700;
    color: #111827;
}

.hero-score-tip {
    display: block;
    margin-top: 8rpx;
    font-size: 20rpx;
    color: #9a6b2f;
}

.hero-highlight {
    border-radius: 22rpx;
    padding: 24rpx;
    background: rgba(255, 255, 255, 0.08);
}

.highlight-title {
    display: block;
    color: #ffffff;
    font-size: 28rpx;
    font-weight: 600;
}

.highlight-desc {
    display: block;
    margin-top: 10rpx;
    color: #d1d5db;
    font-size: 22rpx;
    line-height: 1.7;
}

.highlight-tags {
    display: flex;
    gap: 12rpx;
    margin-top: 18rpx;
    flex-wrap: wrap;
}

.tag {
    padding: 8rpx 16rpx;
    border-radius: 999rpx;
    background: rgba(255, 255, 255, 0.18);
    color: #ffffff;
    font-size: 20rpx;
}

.tag.soft {
    background: rgba(255, 255, 255, 0.08);
    color: #d1d5db;
}

.stats-row {
    margin-top: 20rpx;
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 16rpx;
}

.stat-card {
    border-radius: 22rpx;
    padding: 24rpx 20rpx;
}

.tappable-card {
    position: relative;
    transition: transform 0.15s ease, opacity 0.15s ease;
}

.tappable-card:active {
    transform: scale(0.98);
    opacity: 0.86;
}

.tappable-card::after {
    content: '›';
    position: absolute;
    right: 18rpx;
    top: 18rpx;
    color: #94a3b8;
    font-size: 34rpx;
    font-weight: 700;
}

.accent-card {
    background: linear-gradient(180deg, rgba(255, 248, 236, 0.96) 0%, rgba(255, 243, 227, 0.96) 100%);
}

.stat-value {
    display: block;
    color: #111827;
    font-size: 40rpx;
    font-weight: 700;
}

.stat-label {
    display: block;
    margin-top: 8rpx;
    color: #374151;
    font-size: 24rpx;
}

.stat-foot {
    display: block;
    margin-top: 10rpx;
    color: #9ca3af;
    font-size: 20rpx;
}

.section-card {
    margin-top: 20rpx;
    border-radius: 26rpx;
    padding: 28rpx 24rpx;
}

.section-header {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    gap: 16rpx;
}

.compact-header {
    margin-bottom: 10rpx;
}

.section-title {
    display: block;
    color: #111827;
    font-size: 32rpx;
    font-weight: 700;
}

.section-subtitle {
    display: block;
    margin-top: 8rpx;
    color: #9ca3af;
    font-size: 22rpx;
}

.section-link {
    color: #00a8e8;
    font-size: 22rpx;
}

.quick-grid {
    margin-top: 24rpx;
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18rpx;
}

.quick-item {
    padding: 24rpx 20rpx;
    border-radius: 22rpx;
    background: linear-gradient(180deg, #ffffff 0%, #f7fbfe 100%);
    border: 1rpx solid #edf2f7;
    transition: opacity 0.2s;
}

.quick-item-primary {
    background: linear-gradient(135deg, #e8f7fd 0%, #d9f2fb 100%);
    border-color: #bfdbfe;
}

.quick-item-dim {
    opacity: 0.55;
}

.quick-name-row {
    display: flex;
    align-items: center;
    gap: 10rpx;
    margin-top: 18rpx;
}

.quick-primary-badge {
    font-size: 18rpx;
    padding: 2rpx 10rpx;
    border-radius: 999rpx;
    background: #00a8e8;
    color: #ffffff;
    font-weight: 600;
    line-height: 1.6;
}

.quick-icon {
    width: 72rpx;
    height: 72rpx;
    border-radius: 22rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 10rpx 20rpx rgba(0, 0, 0, 0.08);
}

.quick-icon-dark {
    background: linear-gradient(135deg, #1a2332 0%, #0f5f86 100%);
}

.quick-icon-blue {
    background: linear-gradient(135deg, #00a8e8 0%, #3ec6ff 100%);
}

.quick-icon-orange {
    background: linear-gradient(135deg, #f8a34c 0%, #f9c57f 100%);
}

.quick-icon-green {
    background: linear-gradient(135deg, #22c55e 0%, #86efac 100%);
}

.quick-icon-rose {
    background: linear-gradient(135deg, #ec4899 0%, #f9a8d4 100%);
}

.quick-icon-violet {
    background: linear-gradient(135deg, #7c3aed 0%, #c4b5fd 100%);
}

.quick-name {
    display: block;
    color: #111827;
    font-size: 28rpx;
    font-weight: 600;
}

.quick-tip {
    display: block;
    margin-top: 8rpx;
    color: #6b7280;
    font-size: 22rpx;
    line-height: 1.6;
}

.care-card {
    overflow: hidden;
}

.profile-panels {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16rpx;
    margin-top: 12rpx;
    margin-bottom: 16rpx;
}

.profile-panels-single {
    grid-template-columns: 1fr;
}

.panel-full {
    grid-column: 1 / -1;
}

.profile-panel {
    border-radius: 22rpx;
    padding: 22rpx 20rpx;
}

.tappable-panel {
    position: relative;
    transition: transform 0.15s ease, opacity 0.15s ease;
}

.tappable-panel:active {
    transform: scale(0.98);
    opacity: 0.88;
}

.tappable-panel::after {
    content: '›';
    position: absolute;
    right: 20rpx;
    top: 18rpx;
    color: #9ca3af;
    font-size: 34rpx;
    font-weight: 700;
}

.warm-panel {
    background: linear-gradient(180deg, #fff6ea 0%, #fff0dc 100%);
}

.soft-panel {
    background: linear-gradient(180deg, #eef6ff 0%, #e5f0ff 100%);
}

.panel-badge {
    display: inline-flex;
    padding: 6rpx 14rpx;
    border-radius: 999rpx;
    background: rgba(17, 24, 39, 0.08);
    color: #374151;
    font-size: 20rpx;
}

.panel-badge-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.panel-add-btn {
    display: flex;
    align-items: center;
    gap: 6rpx;
    padding: 6rpx 14rpx;
    border-radius: 999rpx;
    background: rgba(37, 99, 235, 0.08);
}

.panel-add-text {
    color: #00a8e8;
    font-size: 22rpx;
    font-weight: 600;
}

.contact-empty {
    margin-top: 20rpx;
    padding: 24rpx;
    border-radius: 16rpx;
    background: rgba(219, 234, 254, 0.4);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12rpx;
}

.contact-empty-text {
    color: #93c5fd;
    font-size: 22rpx;
}

.add-contact-popup {
    padding-bottom: 0;
}

.add-contact-body {
    padding: 24rpx 32rpx 0;
}

.add-contact-tip {
    display: flex;
    align-items: center;
    gap: 10rpx;
    padding: 16rpx 20rpx;
    border-radius: 14rpx;
    background: #eff6ff;
    margin-bottom: 24rpx;
}

.add-contact-tip-text {
    color: #00a8e8;
    font-size: 22rpx;
    line-height: 1.6;
}

.add-contact-field {
    margin-bottom: 20rpx;
}

.field-label {
    display: block;
    color: #374151;
    font-size: 24rpx;
    font-weight: 600;
    margin-bottom: 12rpx;
}

.field-input {
    width: 100%;
    height: 88rpx;
    padding: 0 24rpx;
    border-radius: 16rpx;
    border: 1rpx solid #e5e7eb;
    background: #f9fafb;
    font-size: 28rpx;
    color: #111827;
    box-sizing: border-box;
}

.code-row {
    display: flex;
    align-items: center;
    gap: 14rpx;
}

.code-input {
    flex: 1;
}

.code-btn {
    width: 220rpx;
    height: 88rpx;
    line-height: 88rpx;
    border-radius: 16rpx;
    background: #00a8e8;
    color: #ffffff;
    font-size: 24rpx;
    border: none;
    padding: 0;
}

.code-btn::after {
    border: none;
}

.code-btn[disabled] {
    opacity: 0.55;
}

.panel-main {
    display: block;
    margin-top: 16rpx;
    color: #111827;
    font-size: 32rpx;
    font-weight: 700;
}

.panel-sub {
    display: block;
    margin-top: 10rpx;
    color: #6b7280;
    font-size: 22rpx;
    line-height: 1.6;
}

.panel-detail-list {
    margin-top: 18rpx;
    padding-top: 16rpx;
    border-top: 1rpx solid rgba(17, 24, 39, 0.08);
}

.detail-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16rpx;
    margin-bottom: 12rpx;
}

.detail-row:last-child {
    margin-bottom: 0;
}

.detail-label {
    color: #6b7280;
    font-size: 22rpx;
}

.detail-value {
    color: #111827;
    font-size: 22rpx;
    font-weight: 600;
    text-align: right;
}

.contact-list {
    margin-top: 18rpx;
    display: flex;
    flex-direction: column;
    gap: 12rpx;
}

.contact-chip {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16rpx;
    padding: 16rpx 18rpx;
    border-radius: 16rpx;
    background: rgba(255, 255, 255, 0.72);
}

.contact-main {
    display: flex;
    flex-direction: column;
    gap: 6rpx;
    flex: 1;
    min-width: 0;
}

.contact-name {
    color: #111827;
    font-size: 22rpx;
    font-weight: 600;
}

.contact-meta {
    color: #6b7280;
    font-size: 20rpx;
}

.contact-phone {
    color: #94a3b8;
    font-size: 20rpx;
}

.care-timeline {
    margin-top: 12rpx;
}

.timeline-item {
    position: relative;
    display: flex;
    gap: 18rpx;
    padding: 18rpx 0 18rpx 4rpx;
}

.timeline-item:not(:last-child)::after {
    content: '';
    position: absolute;
    left: 12rpx;
    top: 44rpx;
    width: 2rpx;
    bottom: -8rpx;
    background: #e5e7eb;
}

.timeline-dot {
    width: 20rpx;
    height: 20rpx;
    border-radius: 50%;
    background: linear-gradient(135deg, #f59e0b 0%, #fcd34d 100%);
    margin-top: 8rpx;
    flex-shrink: 0;
}

.timeline-content {
    flex: 1;
}

.timeline-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12rpx;
}

.timeline-title {
    color: #111827;
    font-size: 28rpx;
    font-weight: 600;
}

.timeline-time {
    color: #9ca3af;
    font-size: 22rpx;
    white-space: nowrap;
}

.timeline-desc {
    display: block;
    margin-top: 10rpx;
    color: #6b7280;
    font-size: 22rpx;
    line-height: 1.7;
}

.service-card .list-item {
    padding: 24rpx 0;
}

.list-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1rpx solid #f1f5f9;
}

.list-item:last-child {
    border-bottom: none;
}

.list-left {
    display: flex;
    align-items: center;
    gap: 18rpx;
}

.list-icon {
    width: 64rpx;
    height: 64rpx;
    border-radius: 18rpx;
    display: flex;
    align-items: center;
    justify-content: center;
}

.list-icon-soft {
    background: #f3f4f6;
}

.list-icon-soft.warm {
    background: #fff2e2;
}

.list-icon-soft.cool {
    background: #eef4ff;
}

.item-title {
    display: block;
    color: #111827;
    font-size: 28rpx;
    font-weight: 600;
}

.item-desc {
    display: block;
    margin-top: 8rpx;
    color: #9ca3af;
    font-size: 22rpx;
    line-height: 1.6;
}

.action-wrap {
    margin: 24rpx 0 40rpx;
    border-radius: 24rpx;
    background: transparent;
    box-shadow: none;
}

.action-btn {
    width: 100%;
    height: 92rpx;
    line-height: 92rpx;
    border-radius: 20rpx;
    border: none;
    font-size: 30rpx;
    font-weight: 700;
}

.action-btn::after {
    border: none;
}

.action-btn.login {
    background: linear-gradient(135deg, #ffffff 0%, #f3f4f6 100%);
    color: #111827;
    box-shadow: 0 16rpx 30rpx rgba(0, 0, 0, 0.16);
}

.action-btn.logout {
    background: rgba(255, 255, 255, 0.12);
    color: #ffffff;
    border: 1rpx solid rgba(255, 255, 255, 0.16);
    backdrop-filter: blur(14rpx);
    -webkit-backdrop-filter: blur(14rpx);
}

.popup-overlay {
    position: fixed;
    inset: 0;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: 99990;
    display: flex;
    align-items: flex-end;
}

.detail-mask {
    z-index: 99991;
}

.unbind-mask {
    z-index: 99994;
}

.add-contact-mask {
    z-index: 99993;
}

.phone-mask {
    z-index: 99992;
}

.popup-content {
    background: #ffffff;
    border-radius: 20rpx 20rpx 0 0;
    width: 100%;
    overflow: hidden;
}

.detail-popup {
    padding-bottom: 24rpx;
}

.unbind-popup {
    width: 100%;
    background: #ffffff;
    border-radius: 24rpx 24rpx 0 0;
    padding: 32rpx 28rpx 24rpx;
    box-sizing: border-box;
}

.unbind-header {
    display: flex;
    flex-direction: column;
    gap: 12rpx;
}

.unbind-title {
    font-size: 32rpx;
    font-weight: 700;
    color: #dc2626;
}

.unbind-desc {
    font-size: 24rpx;
    color: #6b7280;
    line-height: 1.7;
}

.unbind-actions {
    padding: 28rpx 0 0;
}

.detail-card {
    margin: 24rpx 32rpx 0;
    padding: 28rpx 24rpx;
    border-radius: 24rpx;
    background: linear-gradient(180deg, #f8fbff 0%, #eef5ff 100%);
}

.detail-contact-name {
    display: block;
    color: #111827;
    font-size: 34rpx;
    font-weight: 700;
}

.detail-contact-role {
    display: block;
    margin-top: 10rpx;
    color: #6b7280;
    font-size: 24rpx;
}

.detail-info-list {
    margin: 20rpx 32rpx 0;
    border-radius: 22rpx;
    background: #ffffff;
    border: 1rpx solid #edf2f7;
    overflow: hidden;
}

.detail-info-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16rpx;
    padding: 24rpx;
    border-bottom: 1rpx solid #f1f5f9;
}

.detail-info-row:last-child {
    border-bottom: none;
}

.detail-info-label {
    color: #6b7280;
    font-size: 24rpx;
}

.detail-info-value {
    color: #111827;
    font-size: 24rpx;
    font-weight: 600;
    text-align: right;
    flex: 1;
}

.detail-action-row {
    display: flex;
    gap: 18rpx;
    padding: 24rpx 32rpx 0;
}

.detail-action-row-top {
    margin-top: 20rpx;
}

.detail-primary-btn,
.detail-secondary-btn,
.detail-danger-btn {
    flex: 1;
    height: 88rpx;
    line-height: 88rpx;
    border-radius: 18rpx;
    font-size: 28rpx;
    font-weight: 600;
    border: none;
}

.detail-primary-btn::after,
.detail-secondary-btn::after,
.detail-danger-btn::after {
    border: none;
}

.detail-primary-btn {
    background: linear-gradient(135deg, #1a2332 0%, #0f5f86 100%);
    color: #ffffff;
}

.detail-secondary-btn {
    background: #f3f4f6;
    color: #111827;
}

.detail-danger-btn {
    background: linear-gradient(135deg, #ef4444 0%, #f87171 100%);
    color: #ffffff;
}

.popup-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 30rpx 40rpx 20rpx;
    border-bottom: 1px solid #f0f0f0;
}

.popup-header-title {
    font-size: 32rpx;
    font-weight: bold;
    color: #333;
}

.popup-close-btn {
    width: 48rpx;
    height: 48rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background-color: #f5f5f5;
}

.popup-time {
    display: flex;
    align-items: center;
    padding: 20rpx 40rpx;
    background-color: #f8f9fa;
}

.popup-time-text {
    font-size: 24rpx;
    color: #666;
    margin-left: 12rpx;
}

.popup-options {
    padding: 0 40rpx;
}

.popup-option {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 30rpx 0;
    border-bottom: 1px solid #f0f0f0;
}

.popup-option:last-child {
    border-bottom: none;
}

.option-left,
.option-right {
    display: flex;
    align-items: center;
}

.option-title {
    font-size: 28rpx;
    color: #333;
    margin-left: 20rpx;
}

.option-subtitle {
    font-size: 24rpx;
    color: #999;
    margin-right: 12rpx;
}

.popup-cancel {
    background: #f8f9fa;
    height: 100rpx;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 28rpx;
    color: #666;
    border-top: 8rpx solid #f0f0f0;
}

.border-bottom-1px {
    position: relative;
}

.border-bottom-1px::after {
    position: absolute;
    display: block;
    content: '';
    box-sizing: border-box;
    top: 0;
    left: 0;
    width: 200%;
    height: 200%;
    transform: scale(0.5);
    transform-origin: left top;
    border-bottom: 2rpx solid #e5e5e5;
}
</style>
