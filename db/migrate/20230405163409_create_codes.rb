class CreateCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :verfication_codes, id: :uuid do |t|
      t.string :code
      t.references :user, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
