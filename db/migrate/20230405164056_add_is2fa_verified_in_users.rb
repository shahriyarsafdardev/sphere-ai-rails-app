class AddIs2faVerifiedInUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :is_2fa_verified, :boolean
  end
end
