class PostgresReferenceSerializer < ActiveModel::Serializer
  attributes :id, :title, :db_name, :db_user_name, :password, :port, :host
end
