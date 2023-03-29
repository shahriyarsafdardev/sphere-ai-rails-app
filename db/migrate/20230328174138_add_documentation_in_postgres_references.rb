class AddDocumentationInPostgresReferences < ActiveRecord::Migration[6.1]
  def change
    add_column :postgres_references, :documentation, :text
  end
end
