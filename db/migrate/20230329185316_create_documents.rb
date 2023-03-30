# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :documents do |t|
      t.datetime :published_at
      t.string :title
      t.json :transcript, default: []
      t.string :url
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
