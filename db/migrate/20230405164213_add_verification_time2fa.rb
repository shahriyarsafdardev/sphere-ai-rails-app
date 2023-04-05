class AddVerificationTime2fa < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :verification_time_2fa, :datetime
  end
end
