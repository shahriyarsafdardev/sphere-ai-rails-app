# frozen_string_literal: true

class Api::V1::UsersController < ApplicationController
  include UserHelper

  before_action :find_user_through_slug, only: %i[update change_password reset_password]

  def create
    @user = User.new(user_create_params)

    if @user.save
      render json: { message: 'User created successfully' }, status: :ok
    else
      render json: { message: 'Unable to create user' }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_update_params)
      render json: { message: 'User updated successfully' }, status: :ok
    else
      render json: { message: 'Unable to update user' }, status: :unprocessable_entity
    end
  end

  def change_password
    if !@user.valid_password?(params[:old_password])
      render json: { message: 'Incorrect current password provided' }, status: :unprocessable_entity
    elsif params[:new_password].present? && @user.update(password: params[:new_password])
      render json: { message: 'Password saved' }, status: :ok
    else
      render json: { message: 'Failed to update password' }, status: :unprocessable_entity
    end
  end

  def reset_password
    token = @user.create_password_token
    # UserMailer.reset_password(@user, "#{ENV['REACT_APP_URL']}/auth/update-password?reset_password_token=#{token}").deliver_later
    render json: {}, status: :ok
  end

  def update_password
    @user = User.with_reset_password_token(params[:reset_password_token])
    return render json: { message: 'Password reset link expired, please generate a new one' }, status: :unauthorized if @user.blank?

    if params[:password].present? && @user.update(password: params[:password])
      render json: { message: 'Password updated' }, status: :ok
    else
      render json: { message: 'Failed to update password' }, status: :unprocessable_entity
    end
  end

  private

  def devis
    params.require(:user).permit(:first_name, :last_name)
  end
end
