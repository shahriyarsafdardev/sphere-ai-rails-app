class HubspotReferenceSerializer < ActiveModel::Serializer
  attributes :id, :name, :environment, :user_id
end
