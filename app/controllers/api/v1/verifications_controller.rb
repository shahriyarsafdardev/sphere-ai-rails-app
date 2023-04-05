# frozen_string_literal: true

class Api::V1::VerificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_code, only: [:verify, :destroy]

  def create
    code = rand(1000...9999)
    current_user.verification_codes.create!(code: code)
    TWILIO_CLIENT.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: params[:to],
      body: "#{code} - please use this code for 2FA authentication!"
    )
    render json: { message: 'A 4-digit code has been sent to your number!' }, status: :created
  end

  def verify
    if code == params[:code]
      @code.destroy!
      current_user.update(is_2fa_verified: true, verification_time_2fa: Time.zone.now)
      render json: { message: '2FA completed successfully!' }, status: :ok
    else
      render json: { message: 'Something went wrong!' }, status: :unprocessable_entity
    end
  end

  def destroy
    if @code.destroy!
      render json: { message: '2FA destroyed successfully!' }, status: :ok
    else
      render json: { message: 'Something went wrong!' }, status: :unprocessable_entity
    end
  end

  private

  def set_code
    @code = VerificationCode.find_by(id: params[:id])
    return if @code.present?

    render json: { message: 'Verification code not found!' },
           status: :unprocessable_entity
  end
end
