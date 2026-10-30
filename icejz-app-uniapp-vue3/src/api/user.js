import * as request from '../utils/request.js';

/**
 * 获取用户信息
 */
export const useUserInfoApi = () => {
    return request.get('/sys/user/info');
};

/**
 * 更新用户信息
 */
export const useUserInfoSubmitApi = (dataForm) => {
    return request.put('/sys/user/info', dataForm);
};

/**
 * 更新用户头像
 */
export const useUserAvatarApi = (dataForm) => {
    return request.put('/sys/user/avatar', dataForm);
};

/**
 * 修改密码
 */
export const updatePasswordApi = (data) => {
    return request.put('/sys/user/password', data);
};

/**
 * 获取个人中心老人档案/紧急联系人概览
 */
export const useUserMemberSummaryApi = () => {
    return request.get('/sys/user/member-summary');
};

/**
 * 更新联系人备注
 */
export const useFamilyBindingRemarkApi = (data) => {
    return request.put('/member/family-binding/remark', data);
};

/**
 * 解除联系人绑定
 */
export const useFamilyBindingUnbindApi = (data) => {
    return request.del('/member/family-binding/unbind', data);
};

/**
 * 邀请家属绑定（老人发起，通过手机号）
 */
export const useFamilyBindingInviteApi = (data) => {
    return request.post('/member/family-binding/invite', data);
};

export const useFamilyInviteSendCodeApi = (data) => {
    return request.post('/sys/user/family-invite/send-code', data);
};

export const useFamilyBindingConfirmApi = (data) => {
    return request.post('/member/family-binding/confirm', data);
};


export const useSendElderBindCodeApi = (data) => {
    return request.post('/sys/user/elder-bind/send-code', data);
};

/**
 * 确认绑定老人档案
 */
export const useConfirmElderBindApi = (data) => {
    return request.post('/sys/user/elder-bind/confirm', data);
};

/**
 * 我的消息通知
 */
export const useNoticePageApi = (params) => {
    return request.get('/member/notice/page', params);
};

export const useNoticeUnreadCountApi = () => {
    return request.get('/member/notice/unread-count');
};

export const useNoticeReadApi = (id) => {
    return request.put(`/member/notice/${id}/read`);
};

export const useNoticeReadAllApi = () => {
    return request.put('/member/notice/read-all');
};

/**
 * 更新老人档案
 */
export const useElderArchiveSubmitApi = (data) => {
    return data?.id ? request.put('/member/elder-archive', data) : request.post('/member/elder-archive', data);
};

// ===== 服务项目 =====
export const useServiceItemListApi = (category) => {
    return request.get('/member/service-item/list', { category });
};

export const useServiceItemDetailApi = (id) => {
    return request.get(`/member/service-item/${id}`);
};

// ===== 服务预约 =====
export const useBookingCreateApi = (data) => {
    return request.post('/member/booking', data);
};

export const useBookingListApi = (params) => {
    return request.get('/member/booking/page', params);
};

export const useBookingDetailApi = (id) => {
    return request.get(`/member/booking/${id}`);
};

export const useBookingCancelApi = (id, cancelReason) => {
    return request.put(`/member/booking/${id}/status/4`, { cancelReason });
};

// ===== 服务订单 =====
export const useOrderListApi = (params) => {
    return request.get('/member/order/page', params);
};

export const useOrderDetailApi = (id) => {
    return request.get(`/member/order/${id}`);
};

export const useOrderReviewApi = (id, rating, review) => {
    return request.put(`/member/order/${id}/review`, { rating, review });
};

// ===== 健康数据 =====
export const useHealthSummaryApi = (elderUserId) => {
    const params = elderUserId ? { elderUserId } : {};
    return request.get('/member/health-record/summary', params);
};

export const useHealthTrendApi = (recordType, limit = 30, elderUserId) => {
    const params = { recordType, limit };
    if (elderUserId) params.elderUserId = elderUserId;
    return request.get('/member/health-record/trend', params);
};

export const useHealthRecordAddApi = (data) => {
    return request.post('/member/health-record', data);
};

export const useHealthAlertListApi = (params) => {
    return request.get('/member/health-alert/my', params);
};
