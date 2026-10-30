<template>
    <view class="password-container">
        <form @submit="onPassword">
            <view class="form-item">
                <text class="form-label">原密码</text>
                <input 
                    v-model="passwordForm.password"
                    type="password" 
                    name="password" 
                    placeholder="请输入原密码" 
                    class="form-input"
                />
            </view>
            <view class="form-item">
                <text class="form-label">新密码</text>
                <input 
                    v-model="passwordForm.newPassword"
                    type="password" 
                    name="newPassword" 
                    placeholder="请输入新密码" 
                    class="form-input"
                />
            </view>
            <view class="form-item">
                <text class="form-label">确认密码</text>
                <input 
                    v-model="passwordForm.confirmPassword"
                    type="password" 
                    name="confirmPassword" 
                    placeholder="请输入确认密码" 
                    class="form-input"
                />
            </view>
            <view class="password-btn">
                <button type="primary" @click="onPassword" class="save-button">保存</button>
            </view>
        </form>
    </view>
</template>

<script>
import { validateForm } from '../../../utils/validator.js';
import { updatePasswordApi } from '../../../api/user.js';

export default {
    name: 'Password',
    data() {
        return {
            passwordForm: {
                password: '',
                newPassword: '',
                confirmPassword: ''
            }
        };
    },
    onLoad(options) {},
    methods: {
        async onPassword() {
            const dataForm = this.passwordForm;
            const rules = {
                password: [
                    {
                        required: true,
                        message: '原密码不能为空'
                    }
                ],
                newPassword: [
                    {
                        required: true,
                        message: '新密码不能为空'
                    },
                    {
                        pattern: /^.{4,20}$/,
                        message: '新密码必须是4-20位字符'
                    }
                ],
                confirmPassword: [
                    {
                        required: true,
                        message: '确认密码不能为空'
                    }
                ]
            };
            // 表单验证失败
            if (!validateForm(dataForm, rules)) {
                return;
            }
            // 新密码、确认密码，是否相等
            if (dataForm.newPassword != dataForm.confirmPassword) {
                uni.showToast({
                    title: '新密码与确认密码不一致',
                    icon: 'none',
                    duration: 2000
                });
                return;
            }

            // 修改密码
            try {
                await updatePasswordApi(dataForm);
                uni.showToast({
                    title: '密码修改成功',
                    icon: 'success'
                });
                uni.navigateBack();
            } catch (error) {
                console.error('修改密码失败:', error);
            }
        }
    }
};
</script>
<style scoped>
.password-container {
    padding: 40rpx;
    background-color: #f8f8f8;
    min-height: 100vh;
}

.form-item {
    margin-bottom: 30rpx;
    background-color: white;
    padding: 20rpx;
    border-radius: 8rpx;
}

.form-label {
    display: block;
    font-size: 28rpx;
    color: #333;
    margin-bottom: 10rpx;
}

.form-input {
    width: 100%;
    height: 80rpx;
    border: 1px solid #e0e0e0;
    border-radius: 8rpx;
    padding: 0 20rpx;
    font-size: 28rpx;
    background-color: white;
}

.password-btn {
    margin-top: 60rpx;
}

.save-button {
    width: 100%;
    height: 80rpx;
    background-color: #007aff;
    color: white;
    border: none;
    border-radius: 8rpx;
    font-size: 32rpx;
}
</style>
