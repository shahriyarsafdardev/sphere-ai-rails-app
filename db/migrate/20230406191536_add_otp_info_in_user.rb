# frozen_string_literal: true

class AddOtpInfoInUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :otp_verified_at, :datetime
    add_column :users, :is_otp_enabled, :boolean, default: false
  end
end
