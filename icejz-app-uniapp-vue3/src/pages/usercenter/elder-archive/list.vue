<template>
    <view class="elder-page">
        <view class="page-bg">
            <view class="bg-orb orb-gold"></view>
            <view class="bg-orb orb-blue"></view>
        </view>

        <view class="hero-card glass-card">
            <view>
                <text class="hero-eyebrow">老人档案</text>
                <text class="hero-title">{{ pageTitle }}</text>
                <text class="hero-desc">{{ pageDesc }}</text>
            </view>
            <button v-if="!isSelfMode && !isElderRole" class="bind-btn" @tap="goBindPage">绑定老人档案</button>
        </view>

        <view class="summary-row">
            <view class="summary-card glass-card">
                <text class="summary-value">{{ elderArchives.length }}</text>
                <text class="summary-label">已绑定档案</text>
            </view>
            <view class="summary-card glass-card">
                <text class="summary-value">{{ linkedContacts }}</text>
                <text class="summary-label">关联关系</text>
            </view>
        </view>

        <view v-if="elderArchives.length" class="archive-list">
            <view class="archive-card glass-card" v-for="item in elderArchives" :key="item.id" @tap="showArchiveDetail(item)">
                <view class="archive-top">
                    <view class="archive-avatar-wrap">
                        <image :src="item.avatar || '/static/logo.png'" class="archive-avatar" mode="aspectFill" />
                    </view>
                    <view class="archive-meta">
                        <text class="archive-name">{{ item.realName || '未命名档案' }}</text>
                        <text class="archive-sub">{{ formatGender(item.gender) }} · {{ item.mobile || '未填写手机号' }}</text>
                        <view class="archive-tags">
                            <text class="archive-tag">{{ item.healthStatus || '健康状态待更新' }}</text>
                            <text class="archive-tag soft">已绑定</text>
                            <text v-if="item.relationType" class="archive-tag relation">{{ item.relationType }}</text>
                        </view>
                    </view>
                </view>
                <view class="archive-info-grid">
                    <view class="info-chip">
                        <text class="info-chip-label">关系类型</text>
                        <text class="info-chip-value">{{ item.relationType || '未填写' }}</text>
                    </view>
                    <view class="info-chip">
                        <text class="info-chip-label">绑定备注</text>
                        <text class="info-chip-value">{{ item.bindingRemark || '暂无备注' }}</text>
                    </view>
                    <view class="info-chip">
                        <text class="info-chip-label">紧急联系人</text>
                        <text class="info-chip-value">{{ item.emergencyContactName || '未填写' }}</text>
                    </view>
                    <view class="info-chip">
                        <text class="info-chip-label">联系电话</text>
                        <text class="info-chip-value">{{ item.emergencyContactMobile || '未填写' }}</text>
                    </view>
                    <view class="info-chip full">
                        <text class="info-chip-label">家庭住址</text>
                        <text class="info-chip-value">{{ formatAddress(item) }}</text>
                    </view>
                </view>
                <view class="archive-action-row" @tap.stop>
                    <button v-if="isSelfMode" class="archive-secondary-btn" @tap="openEditArchive(item)">修改档案</button>
                    <button v-else class="archive-secondary-btn" @tap="showRelationDetail(item)">查看绑定关系</button>
                    <button v-if="!isSelfMode" class="archive-danger-btn" @tap="unbindArchive(item)">解除绑定</button>
                </view>
                <view class="archive-arrow">
                    <uni-icons type="arrowright" size="18" color="#94a3b8" />
                </view>
            </view>
        </view>

        <view v-else class="empty-card glass-card">
            <image src="/static/logo.png" class="empty-logo" mode="aspectFit" />
            <text class="empty-title">{{ emptyTitle }}</text>
            <text class="empty-desc">{{ emptyDesc }}</text>
            <button v-if="!isSelfMode" class="empty-btn" @tap="goBindPage">立即绑定</button>
            <button v-else class="empty-btn" @tap="openEditArchive({})">新建本人档案</button>
        </view>

        <view v-if="showEditPopup" class="popup-overlay" @tap="closeEditArchive">
            <view class="edit-popup" @tap.stop>
                <view class="popup-header">
                    <text class="popup-title">{{ editForm.id ? '修改老人档案' : '新建老人档案' }}</text>
                    <view class="popup-close" @tap="closeEditArchive">
                        <uni-icons type="closeempty" size="22" color="#64748b" />
                    </view>
                </view>
                <scroll-view scroll-y class="edit-body">
                    <view class="form-item">
                        <text class="form-label">姓名</text>
                        <input class="form-input" v-model="editForm.realName" placeholder="请输入姓名" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">手机号</text>
                        <input class="form-input" v-model="editForm.mobile" type="number" maxlength="11" placeholder="请输入手机号" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">性别</text>
                        <picker :range="genderOptions" range-key="label" :value="genderIndex" @change="onGenderChange">
                            <view class="form-input picker-input">{{ genderText }}</view>
                        </picker>
                    </view>
                    <view class="form-item">
                        <text class="form-label">出生日期</text>
                        <picker mode="date" :value="editForm.birthday || ''" @change="onBirthdayChange">
                            <view class="form-input picker-input">{{ editForm.birthday || '请选择出生日期' }}</view>
                        </picker>
                    </view>
                    <view class="form-item">
                        <text class="form-label">身份证号</text>
                        <input class="form-input" v-model="editForm.idCardNo" placeholder="请输入身份证号" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">健康状态</text>
                        <input class="form-input" v-model="editForm.healthStatus" placeholder="如：良好、待完善、需关注" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">慢病情况</text>
                        <textarea class="form-textarea" v-model="editForm.chronicDisease" placeholder="请输入慢病情况" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">过敏史</text>
                        <textarea class="form-textarea" v-model="editForm.allergyHistory" placeholder="请输入过敏史" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">紧急联系人</text>
                        <input class="form-input" v-model="editForm.emergencyContactName" placeholder="请输入紧急联系人姓名" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">联系人关系</text>
                        <input class="form-input" v-model="editForm.emergencyContactRelation" placeholder="如：儿子、女儿、配偶" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">联系人电话</text>
                        <input class="form-input" v-model="editForm.emergencyContactMobile" type="number" maxlength="11" placeholder="请输入紧急联系人电话" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">所在地区</text>
                        <view class="area-row">
                            <input class="form-input area-input" v-model="editForm.province" placeholder="省" />
                            <input class="form-input area-input" v-model="editForm.city" placeholder="市" />
                            <input class="form-input area-input" v-model="editForm.district" placeholder="区" />
                        </view>
                    </view>
                    <view class="form-item">
                        <text class="form-label">详细地址</text>
                        <input class="form-input" v-model="editForm.address" placeholder="请输入详细地址" />
                    </view>
                    <view class="form-item">
                        <text class="form-label">备注</text>
                        <textarea class="form-textarea" v-model="editForm.remark" placeholder="请输入备注" />
                    </view>
                </scroll-view>
                <view class="popup-actions">
                    <button class="cancel-btn" @tap="closeEditArchive">取消</button>
                    <button class="save-btn" :disabled="saving" @tap="submitEditArchive">{{ saving ? '保存中...' : '保存' }}</button>
                </view>
            </view>
        </view>
    </view>
</template>

<script>
import cache from '../../../utils/cache.js';
import { useElderArchiveSubmitApi, useFamilyBindingUnbindApi, useUserMemberSummaryApi } from '../../../api/user.js';

export default {
    name: 'ElderArchiveList',
    data() {
        return {
            elderArchives: [],
            linkedContacts: 0,
            isSelfMode: false,
            isElderRole: false,
            showEditPopup: false,
            saving: false,
            genderOptions: [
                { label: '男', value: 0 },
                { label: '女', value: 1 },
                { label: '未知', value: 2 }
            ],
            editForm: {}
        };
    },
    computed: {
        pageTitle() {
            return this.isSelfMode ? '我的健康档案' : '已绑定长者档案';
        },
        pageDesc() {
            return this.isSelfMode ? '查看本人老人健康档案、健康状态、紧急联系人和基础信息。' : '查看已关联的老人资料，也可以继续绑定新的老人档案。';
        },
        emptyTitle() {
            return this.isSelfMode ? '暂无老人健康档案' : '还没有绑定老人档案';
        },
        emptyDesc() {
            return this.isSelfMode ? '当前账号还没有建立老人健康档案，可点击下方按钮新建本人档案。' : '通过手机号和验证码即可快速绑定老人档案，完成后可在这里统一查看。';
        },
        genderIndex() {
            const index = this.genderOptions.findIndex(item => item.value === this.editForm.gender);
            return index >= 0 ? index : 2;
        },
        genderText() {
            return this.genderOptions[this.genderIndex]?.label || '未知';
        }
    },
    onLoad(query) {
        const userInfo = cache.getUserInfo() || {};
        const roleIdList = Array.isArray(userInfo.roleIdList) ? userInfo.roleIdList : [];
        this.isElderRole = roleIdList.includes(303);
        this.isSelfMode = query?.mode === 'self' || this.isElderRole;
    },
    async onShow() {
        await this.loadData();
    },
    methods: {
        async loadData() {
            try {
                const response = await useUserMemberSummaryApi();
                const data = response?.data || {};
                if (this.isSelfMode) {
                    this.elderArchives = data.elderArchive ? [data.elderArchive] : [];
                } else {
                    this.elderArchives = Array.isArray(data.elderArchives) ? data.elderArchives : [];
                }
                this.linkedContacts = Number(data.familyBindingCount || 0);
            } catch (error) {
                console.error('load elder archives error', error);
            }
        },
        goBindPage() {
            if (this.isSelfMode || this.isElderRole) {
                uni.showToast({ title: '当前为本人健康档案，无需绑定老人', icon: 'none' });
                return;
            }
            uni.navigateTo({ url: '/pages/usercenter/elder-archive/bind' });
        },
        openEditArchive(item = {}) {
            const userInfo = cache.getUserInfo() || {};
            this.editForm = {
                id: item.id || undefined,
                memberUserId: item.memberUserId || userInfo.id,
                realName: item.realName || userInfo.realName || '',
                idCardNo: item.idCardNo || '',
                gender: item.gender ?? userInfo.gender ?? 2,
                birthday: item.birthday || '',
                mobile: item.mobile || userInfo.mobile || '',
                avatar: item.avatar || userInfo.avatar || '',
                province: item.province || '',
                city: item.city || '',
                district: item.district || '',
                address: item.address || '',
                healthStatus: item.healthStatus || '待完善',
                chronicDisease: item.chronicDisease || '',
                allergyHistory: item.allergyHistory || '',
                emergencyContactName: item.emergencyContactName || '',
                emergencyContactRelation: item.emergencyContactRelation || '',
                emergencyContactMobile: item.emergencyContactMobile || '',
                remark: item.remark || '',
                status: item.status ?? 1
            };
            this.showEditPopup = true;
        },
        closeEditArchive() {
            this.showEditPopup = false;
            this.editForm = {};
        },
        onGenderChange(e) {
            const index = Number(e.detail.value);
            this.editForm.gender = this.genderOptions[index]?.value ?? 2;
        },
        onBirthdayChange(e) {
            this.editForm.birthday = e.detail.value;
        },
        async submitEditArchive() {
            const realName = (this.editForm.realName || '').trim();
            const mobile = (this.editForm.mobile || '').trim();
            const emergencyMobile = (this.editForm.emergencyContactMobile || '').trim();
            if (!realName) {
                uni.showToast({ title: '请输入姓名', icon: 'none' });
                return;
            }
            if (mobile && !/^1\d{10}$/.test(mobile)) {
                uni.showToast({ title: '请输入正确手机号', icon: 'none' });
                return;
            }
            if (emergencyMobile && !/^1\d{10}$/.test(emergencyMobile)) {
                uni.showToast({ title: '请输入正确联系人电话', icon: 'none' });
                return;
            }
            this.saving = true;
            try {
                await useElderArchiveSubmitApi({ ...this.editForm, realName, mobile, emergencyContactMobile: emergencyMobile });
                uni.showToast({ title: '档案已保存', icon: 'success' });
                this.closeEditArchive();
                await this.loadData();
            } catch (error) {
                console.error('submit elder archive error', error);
                uni.showToast({ title: '保存失败，请稍后重试', icon: 'none' });
            } finally {
                this.saving = false;
            }
        },
        formatGender(gender) {
            if (gender === 0) return '男';
            if (gender === 1) return '女';
            return '未知';
        },
        formatAddress(item) {
            return [item.province, item.city, item.district, item.address].filter(Boolean).join('') || '未填写';
        },
        showRelationDetail(item) {
            const relationLines = [
                `老人姓名：${item.realName || '未填写'}`,
                `关系类型：${item.relationType || '未填写'}`,
                `绑定备注：${item.bindingRemark || '暂无备注'}`,
                `联系电话：${item.mobile || '未填写'}`
            ];
            uni.showModal({
                title: '绑定关系',
                content: relationLines.join('\n'),
                showCancel: false
            });
        },
        async unbindArchive(item) {
            if (!item?.memberUserId) {
                uni.showToast({ title: '未找到绑定关系', icon: 'none' });
                return;
            }
            uni.showModal({
                title: '解除绑定',
                content: `确定要解除与${item.realName || '该老人'}的绑定关系吗？`,
                success: async (res) => {
                    if (!res.confirm) return;
                    try {
                        await useFamilyBindingUnbindApi({
                            elderMemberUserId: item.memberUserId,
                            familyMemberUserId: item.familyMemberUserId
                        });
                        uni.showToast({ title: '已解除绑定', icon: 'success' });
                        await this.loadData();
                    } catch (error) {
                        console.error('unbind elder archive error', error);
                    }
                }
            });
        },
        showArchiveDetail(item) {
            const detailLines = [
                `姓名：${item.realName || '未填写'}`,
                `性别：${this.formatGender(item.gender)}`,
                `手机号：${item.mobile || '未填写'}`,
                `健康状态：${item.healthStatus || '暂无记录'}`,
                `慢病情况：${item.chronicDisease || '暂无记录'}`,
                `过敏史：${item.allergyHistory || '暂无记录'}`,
                `关系类型：${item.relationType || '未填写'}`,
                `绑定备注：${item.bindingRemark || '暂无备注'}`,
                `紧急联系人：${item.emergencyContactName || '未填写'}`,
                `紧急联系人电话：${item.emergencyContactMobile || '未填写'}`,
                `住址：${this.formatAddress(item)}`
            ];
            uni.showModal({
                title: '老人档案详情',
                content: detailLines.join('\n'),
                showCancel: false
            });
        }
    }
};
</script>

<style scoped>
.elder-page {
    min-height: 100vh;
    position: relative;
    overflow: hidden;
    padding: 28rpx 24rpx 48rpx;
    background: linear-gradient(180deg, #f8fafc 0%, #eef2ff 100%);
}

.page-bg {
    position: absolute;
    inset: 0;
    pointer-events: none;
}

.bg-orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(100rpx);
    opacity: 0.55;
}

.orb-gold {
    width: 320rpx;
    height: 320rpx;
    left: -80rpx;
    top: -40rpx;
    background: rgba(250, 204, 21, 0.26);
}

.orb-blue {
    width: 360rpx;
    height: 360rpx;
    right: -120rpx;
    top: 240rpx;
    background: rgba(96, 165, 250, 0.24);
}

.glass-card {
    position: relative;
    z-index: 1;
    background: rgba(255, 255, 255, 0.88);
    border: 1rpx solid rgba(255, 255, 255, 0.74);
    box-shadow: 0 24rpx 60rpx rgba(15, 23, 42, 0.08);
    backdrop-filter: blur(20rpx);
    -webkit-backdrop-filter: blur(20rpx);
}

.hero-card {
    border-radius: 30rpx;
    padding: 30rpx;
}

.hero-eyebrow {
    display: block;
    color: #64748b;
    font-size: 22rpx;
    letter-spacing: 4rpx;
}

.hero-title {
    display: block;
    margin-top: 12rpx;
    color: #0f172a;
    font-size: 40rpx;
    font-weight: 700;
}

.hero-desc {
    display: block;
    margin-top: 12rpx;
    color: #64748b;
    font-size: 24rpx;
    line-height: 1.7;
}

.bind-btn,
.empty-btn {
    margin-top: 24rpx;
    width: 100%;
    height: 88rpx;
    line-height: 88rpx;
    border-radius: 20rpx;
    border: none;
    color: #ffffff;
    font-size: 28rpx;
    font-weight: 700;
    background: linear-gradient(135deg, #121a28 0%, #00a8e8 100%);
}

.bind-btn::after,
.empty-btn::after {
    border: none;
}

.summary-row {
    margin-top: 18rpx;
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16rpx;
}

.summary-card {
    border-radius: 24rpx;
    padding: 24rpx;
}

.summary-value {
    display: block;
    color: #0f172a;
    font-size: 40rpx;
    font-weight: 700;
}

.summary-label {
    display: block;
    margin-top: 8rpx;
    color: #94a3b8;
    font-size: 22rpx;
}

.archive-list {
    margin-top: 18rpx;
    display: flex;
    flex-direction: column;
    gap: 16rpx;
}

.archive-card {
    border-radius: 28rpx;
    padding: 24rpx;
}

.archive-top {
    display: flex;
    gap: 18rpx;
}

.archive-avatar-wrap {
    width: 110rpx;
    height: 110rpx;
    border-radius: 32rpx;
    background: linear-gradient(180deg, #f8fafc 0%, #e2e8f0 100%);
    overflow: hidden;
    flex-shrink: 0;
}

.archive-avatar {
    width: 100%;
    height: 100%;
}

.archive-meta {
    flex: 1;
    min-width: 0;
}

.archive-name {
    display: block;
    color: #111827;
    font-size: 32rpx;
    font-weight: 700;
}

.archive-sub {
    display: block;
    margin-top: 8rpx;
    color: #64748b;
    font-size: 22rpx;
}

.archive-tags {
    display: flex;
    gap: 10rpx;
    flex-wrap: wrap;
    margin-top: 14rpx;
}

.archive-tag {
    padding: 8rpx 14rpx;
    border-radius: 999rpx;
    background: #e0f2fe;
    color: #0369a1;
    font-size: 20rpx;
}

.archive-tag.soft {
    background: #ecfdf5;
    color: #047857;
}

.archive-info-grid {
    margin-top: 20rpx;
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 14rpx;
}

.info-chip {
    padding: 18rpx;
    border-radius: 20rpx;
    background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
    border: 1rpx solid #edf2f7;
}

.info-chip.full {
    grid-column: 1 / -1;
}

.info-chip-label {
    display: block;
    color: #94a3b8;
    font-size: 20rpx;
}

.info-chip-value {
    display: block;
    margin-top: 8rpx;
    color: #0f172a;
    font-size: 24rpx;
    font-weight: 600;
    line-height: 1.6;
}

.archive-action-row {
    margin-top: 22rpx;
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 14rpx;
}

.archive-secondary-btn,
.archive-danger-btn {
    height: 76rpx;
    line-height: 76rpx;
    border-radius: 18rpx;
    border: none;
    font-size: 26rpx;
    font-weight: 600;
}

.archive-secondary-btn::after,
.archive-danger-btn::after {
    border: none;
}

.archive-secondary-btn {
    background: #eff6ff;
    color: #00a8e8;
}

.archive-danger-btn {
    background: #fef2f2;
    color: #ef4444;
}

.archive-action-row .archive-secondary-btn:only-child {
    grid-column: 1 / -1;
}

.archive-arrow {
    margin-top: 18rpx;
    display: flex;
    justify-content: flex-end;
}

.popup-overlay {
    position: fixed;
    inset: 0;
    z-index: 999;
    background: rgba(15, 23, 42, 0.48);
    display: flex;
    align-items: flex-end;
}

.edit-popup {
    width: 100%;
    max-height: 88vh;
    background: #ffffff;
    border-radius: 28rpx 28rpx 0 0;
    overflow: hidden;
}

.popup-header {
    padding: 30rpx 32rpx 22rpx;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1rpx solid #f1f5f9;
}

.popup-title {
    color: #0f172a;
    font-size: 32rpx;
    font-weight: 700;
}

.popup-close {
    width: 52rpx;
    height: 52rpx;
    border-radius: 50%;
    background: #f8fafc;
    display: flex;
    align-items: center;
    justify-content: center;
}

.edit-body {
    max-height: 62vh;
    padding: 24rpx 32rpx;
    box-sizing: border-box;
}

.form-item {
    margin-bottom: 22rpx;
}

.form-label {
    display: block;
    margin-bottom: 12rpx;
    color: #334155;
    font-size: 24rpx;
    font-weight: 600;
}

.form-input,
.form-textarea {
    width: 100%;
    border-radius: 16rpx;
    border: 1rpx solid #e5e7eb;
    background: #f8fafc;
    color: #0f172a;
    font-size: 26rpx;
    box-sizing: border-box;
}

.form-input {
    height: 84rpx;
    padding: 0 22rpx;
}

.picker-input {
    line-height: 84rpx;
    color: #0f172a;
}

.form-textarea {
    min-height: 130rpx;
    padding: 20rpx 22rpx;
    line-height: 1.6;
}

.area-row {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 12rpx;
}

.area-input {
    padding: 0 14rpx;
}

.popup-actions {
    padding: 20rpx 32rpx 28rpx;
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16rpx;
    border-top: 1rpx solid #f1f5f9;
}

.cancel-btn,
.save-btn {
    height: 86rpx;
    line-height: 86rpx;
    border-radius: 18rpx;
    border: none;
    font-size: 28rpx;
    font-weight: 700;
}

.cancel-btn::after,
.save-btn::after {
    border: none;
}

.cancel-btn {
    background: #f1f5f9;
    color: #334155;
}

.save-btn {
    background: linear-gradient(135deg, #121a28 0%, #00a8e8 100%);
    color: #ffffff;
}

.empty-card {
    margin-top: 18rpx;
    border-radius: 30rpx;
    padding: 48rpx 28rpx;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
}

.empty-logo {
    width: 120rpx;
    height: 120rpx;
    opacity: 0.88;
}

.empty-title {
    display: block;
    margin-top: 24rpx;
    color: #111827;
    font-size: 34rpx;
    font-weight: 700;
}

.empty-desc {
    display: block;
    margin-top: 14rpx;
    color: #64748b;
    font-size: 24rpx;
    line-height: 1.8;
}
</style>
