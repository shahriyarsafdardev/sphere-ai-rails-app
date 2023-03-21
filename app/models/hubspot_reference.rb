class HubspotReference < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :hubspot_access_token, presence: true
  validates :environment, presence: true
end
