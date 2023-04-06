class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :role, :authenticator_hex
  attribute :message, if: :show_message?

  def message
    @instance_options[:message]
  end

  def show_message?
    @instance_options[:message].present?
  end
end
