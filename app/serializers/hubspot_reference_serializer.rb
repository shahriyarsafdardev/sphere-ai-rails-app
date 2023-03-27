class HubspotReferenceSerializer < ActiveModel::Serializer
  attributes :id, :name, :hubspot_access_token, :environment, :user_id
end
