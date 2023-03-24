# frozen_string_literal: true

module UserHelper
  extend ActiveSupport::Concern

  def find_user_through_slug
    @user = User.friendly.find(params[:id])
  rescue StandardError => _e
    render json: { message: 'User not found' }, status: :unprocessable_entity
  end

  def find_user_through_email
    @user = User.find_by(email: params[:email])
    render json: { message: 'User not found' }, status: :unprocessable_entity if @user.blank?
  end
end
