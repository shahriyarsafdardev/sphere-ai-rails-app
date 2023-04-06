# frozen_string_literal: true

class Api::V1::OtpSecretsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_totp_secret, only: [:verify]

  def create
    unless current_user.otp_secret?
      @otp_secret = ROTP::Base32.random
      current_user.update(otp_secret: @otp_secret)
    end
    set_totp_secret
    qr_link = @totp.provisioning_uri(current_user.email)

    render json: { qr_link: qr_link }, status: :ok
  end

  def verify
    otp_verified_at = @totp.verify(params[:otp_code], drift_behind: 15)
    if otp_verified_at
      current_user.update(otp_verified_at: DateTime.now)

      render json: { message: 'Successfully verified!' }, status: :ok
    else
      render json: { message: 'Invalid otp code!' }, status: :unprocessable_entity
    end
  end

  private

  def set_totp_secret
    @totp = ROTP::TOTP.new(
      current_user&.otp_secret, issuer: 'Sphere AI'
    )
  end
end
