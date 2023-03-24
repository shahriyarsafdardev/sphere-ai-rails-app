# frozen_string_literal: true

class CreatePostgresReferences < ActiveRecord::Migration[6.0]
  def change
    create_table :postgres_references, id: :uuid do |t|
      t.string :title, null: false
      t.string :db_name, null: false
      t.string :db_user_name, null: false
      t.string :password, null: false
      t.string :host, null: false
      t.integer :port, null: false
      t.references :user, type: :uuid, null: false, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
