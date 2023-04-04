class RemoveUserReferences < ActiveRecord::Migration[6.1]
  def change
    remove_reference :postgres_references, :user, type: :uuid, index: true, foreign_key: true
    remove_reference :hubspot_references, :user, type: :uuid, foreign_key: true
  end
end
