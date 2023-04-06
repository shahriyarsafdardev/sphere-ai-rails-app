class AddHexToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :authenticator_hex, :string
  end
end
