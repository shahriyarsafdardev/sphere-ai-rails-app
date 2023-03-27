# frozen_string_literal: true

class HubspotReference < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :hubspot_access_token, presence: true
  validates :environment, presence: true


  def run_query(query)
    result = GptService.query_with_hubspot_reference(query, id)
    { query: query, result: result }
  end 
end
