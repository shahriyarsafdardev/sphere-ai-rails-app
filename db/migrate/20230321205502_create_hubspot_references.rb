# frozen_string_literal: true

class CreateHubspotReferences < ActiveRecord::Migration[6.1]
  def change
    create_table :hubspot_references, id: :uuid do |t|
      t.string :name, null: false, default: ''
      t.string :hubspot_access_token, null: false, default: ''
      t.string :environment, null: false, default: ''
      t.references :user, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
