<template>
  <view class="page">
    <view class="card head">
      <text class="title">{{ isCreate ? '发起预约' : '预约详情' }}</text>
      <text class="sub">{{ isCreate ? '填写预约信息，等待服务人员确认' : '查看预约进度与服务信息' }}</text>
    </view>

    <!-- 创建预约表单 -->
    <view v-if="isCreate" class="card">
      <text class="section">预约信息</text>
      <view class="form-item" v-if="elderOptions.length > 1">
        <text class="label">预约老人</text>
        <picker :range="elderOptions" range-key="realName" @change="onElderChange">
          <text class="value picker-val">{{ selectedElderName || '请选择老人' }}</text>
        </picker>
      </view>
      <view class="form-item">
        <text class="label">服务项目</text>
        <text class="value">{{ form.serviceName || '请选择服务' }}</text>
      </view>
      <view class="form-item">
        <text class="label">预约时间</text>
        <picker mode="date" @change="onDateChange">
          <text class="value picker-val">{{ form.bookingDate || '请选择日期' }}</text>
        </picker>
      </view>
      <view class="form-item">
        <text class="label">服务地址</text>
        <input class="input" v-model="form.address" placeholder="请输入服务地址" />
      </view>
      <view class="form-item">
        <text class="label">联系人</text>
        <input class="input" v-model="form.contactName" placeholder="联系人姓名" />
      </view>
      <view class="form-item">
        <text class="label">联系电话</text>
        <input class="input" type="number" v-model="form.contactMobile" placeholder="联系电话" />
      </view>
      <view class="form-item">
        <text class="label">备注</text>
        <input class="input" v-model="form.remark" placeholder="其他说明（可选）" />
      </view>
      <button class="btn" :loading="submitting" @click="submitBooking">提交预约</button>
    </view>

    <!-- 预约详情 -->
    <view v-else class="card">
      <text class="section">预约信息</text>
      <view class="row"><text>服务项目</text><text>{{ booking.serviceName }}</text></view>
      <view class="row"><text>预约时间</text><text>{{ booking.bookingTime }}</text></view>
      <view class="row"><text>服务地址</text><text>{{ booking.address || '-' }}</text></view>
      <view class="row"><text>联系人</text><text>{{ booking.contactName }} {{ booking.contactMobile }}</text></view>
      <view class="row"><text>服务人员</text><text>{{ booking.workerName || '待分配' }}</text></view>
      <view class="row"><text>预约状态</text><text class="status">{{ statusLabel(booking.status) }}</text></view>
    </view>

    <view v-if="!isCreate && booking.id" class="card">
      <button v-if="[0,1].includes(booking.status)" class="btn cancel-btn" @click="cancelBooking">取消预约</button>
      <button class="btn contact-btn" @click="onContact">联系客服</button>
    </view>
  </view>
</template>

<script>
import { useBookingCreateApi, useBookingDetailApi, useBookingCancelApi, useUserMemberSummaryApi } from '../../../../api/user.js';
import cache from '../../../../utils/cache.js';

export default {
  name: 'HomeCareBooking',
  data() {
    return {
      isCreate: false,
      submitting: false,
      elderOptions: [],
      selectedElderIndex: 0,
      selectedElderName: '',
      form: { serviceItemId: '', serviceName: '', bookingDate: '', address: '', contactName: '', contactMobile: '', remark: '' },
      booking: {}
    };
  },
  onLoad(query) {
    const user = cache.getUserInfo() || {};
    if (query?.serviceItemId) {
      this.isCreate = true;
      this.form.serviceItemId = query.serviceItemId;
      this.form.serviceName = decodeURIComponent(query.serviceName || '');
      this.form.contactName = user.realName || '';
      this.form.contactMobile = user.mobile || '';
      this.loadElderOptions();
    } else if (query?.id) {
      this.loadBooking(query.id);
    }
  },
  methods: {
    async loadElderOptions() {
      try {
        const res = await useUserMemberSummaryApi();
        const data = res?.data || {};
        this.elderOptions = Array.isArray(data.elderArchives) ? data.elderArchives : [];
        this.selectedElderIndex = 0;
        this.selectedElderName = this.elderOptions[0]?.realName || '';
      } catch (e) {
        this.elderOptions = [];
      }
    },
    onElderChange(e) {
      const idx = Number(e.detail.value || 0);
      this.selectedElderIndex = idx;
      this.selectedElderName = this.elderOptions[idx]?.realName || '';
    },
    async loadBooking(id) {
      const res = await useBookingDetailApi(id);
      this.booking = res?.data || {};
    },
    onDateChange(e) {
      this.form.bookingDate = e.detail.value;
    },
    async submitBooking() {
      if (!this.form.bookingDate) { uni.showToast({ title: '请选择预约时间', icon: 'none' }); return; }
      if (!this.form.address) { uni.showToast({ title: '请填写服务地址', icon: 'none' }); return; }
      this.submitting = true;
      try {
        const user = cache.getUserInfo() || {};
        const elder = this.elderOptions[this.selectedElderIndex] || user;
        await useBookingCreateApi({
          serviceItemId: this.form.serviceItemId,
          elderUserId: elder.memberUserId || elder.id || user.id,
          elderName: elder.realName || user.realName,
          elderMobile: elder.mobile || user.mobile,
          bookingTime: this.form.bookingDate + ' 09:00:00',
          address: this.form.address,
          contactName: this.form.contactName,
          contactMobile: this.form.contactMobile,
          remark: this.form.remark
        });
        uni.showToast({ title: '预约成功，等待确认', icon: 'success', duration: 2000 });
        setTimeout(() => uni.navigateBack(), 2000);
      } catch (e) {
        uni.showToast({ title: '预约失败，请重试', icon: 'none' });
      } finally {
        this.submitting = false;
      }
    },
    async cancelBooking() {
      uni.showModal({
        title: '取消预约',
        content: '确定要取消该预约吗？',
        success: async (res) => {
          if (!res.confirm) return;
          await useBookingCancelApi(this.booking.id, '用户主动取消');
          uni.showToast({ title: '已取消', icon: 'success' });
          await this.loadBooking(this.booking.id);
        }
      });
    },
    onContact() {
      uni.setClipboardData({
        data: '960681673',
        success: () => uni.showToast({ title: 'QQ已复制：960681673', icon: 'none' })
      });
    },
    statusLabel(s) {
      return ['待确认','已确认','服务中','已完成','已取消'][s] || '-';
    }
  }
};
</script>

<style scoped>
.page { min-height:100vh; background:#f6f6f6; padding:24rpx; }
.card { background:#fff; border-radius:18rpx; padding:24rpx; margin-bottom:18rpx; }
.head { background:#111; }
.title { display:block; color:#fff; font-size:34rpx; font-weight:700; }
.sub { display:block; color:#d3d3d3; font-size:22rpx; margin-top:8rpx; }
.section { display:block; color:#111; font-size:28rpx; font-weight:600; margin-bottom:16rpx; }
.form-item { display:flex; justify-content:space-between; align-items:center; padding:18rpx 0; border-bottom:1rpx solid #f1f1f1; }
.form-item:last-of-type { border-bottom:none; }
.label { color:#666; font-size:26rpx; width:160rpx; flex-shrink:0; }
.value { color:#111; font-size:26rpx; flex:1; text-align:right; }
.picker-val { color:#00a8e8; }
.input { flex:1; text-align:right; font-size:26rpx; color:#111; }
.row { display:flex; justify-content:space-between; padding:14rpx 0; border-bottom:1rpx solid #f1f1f1; font-size:24rpx; color:#333; }
.row:last-child { border-bottom:none; }
.status { font-weight:700; color:#111; }
.btn { margin-top:20rpx; background:#111; color:#fff; border-radius:14rpx; height:88rpx; line-height:88rpx; font-size:30rpx; }
.btn::after { border:none; }
.cancel-btn { background:#ef4444; margin-bottom:16rpx; }
.contact-btn { background:#f3f4f6; color:#111; }
</style>
