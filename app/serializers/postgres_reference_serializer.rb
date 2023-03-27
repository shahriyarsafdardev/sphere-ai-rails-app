class PostgresReferenceSerializer < ActiveModel::Serializer
  attributes :id, :title, :db_name, :db_user_name, :host
  attribute :message, if: :show_message?

  def message
    @instance_options[:message]
  end

  def show_message?
    @instance_options[:message].present?
  end
end
