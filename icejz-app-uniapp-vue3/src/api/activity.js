import * as request from '../utils/request.js';

export const useActivityPageApi = (params) => {
    return request.get('/member/activity/page', params);
};

export const useActivityDetailApi = (id) => {
    return request.get(`/member/activity/${id}`);
};

export const useActivitySignupApi = (data) => {
    return request.post('/member/activity-signup/signup', data);
};

export const useMyActivitySignupPageApi = (params) => {
    return request.get('/member/activity-signup/my/page', params);
};

export const useActivityReviewSubmitApi = (data) => {
    return request.post('/member/activity-review/submit', data);
};

export const useActivityReviewPageApi = (params) => {
    return request.get('/member/activity-review/page', params);
};

export const useMyActivityReviewPageApi = (params) => {
    return request.get('/member/activity-review/my/page', params);
};

export const useActivityReviewStatsApi = (activityId) => {
    return request.get(`/member/activity-review/stats/${activityId}`);
};
