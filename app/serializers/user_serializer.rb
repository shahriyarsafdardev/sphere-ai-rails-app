class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :role, :is_otp_enabled, :otp_verified_at
  attribute :message, if: :show_message?
  attribute :is_qr_scanned
  attribute :is_otp_verified

  def message
    @instance_options[:message]
  end

  def show_message?
    @instance_options[:message].present?
  end

  def is_qr_scanned
    object.otp_verified_at.present?
  end

  def is_otp_verified
    object.is_otp_verified && object.otp_verified_at && (DateTime.now - object.otp_verified_at.to_datetime).to_i <= 7
  end
end
