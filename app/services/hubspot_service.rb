require 'hubspot-api-client'
require 'hubspot-ruby'

class HubspotService
  class << self
    def configure_client(access_token)
      Hubspot.configure({
                          access_token: access_token,
                          base_url: 'https://api.hubapi.com',
                        })
    end

    def connect_client(access_token)
      Hubspot::Client.new(access_token: access_token)
    end

    def get_all_contacts(access_token)
      configure_client(access_token)
      Hubspot::Contact.all
    end

    def get_schema(object_type, access_token)
      api_client = connect_client(access_token)
      api_response = api_client.crm.properties.core_api.get_all(object_type: object_type, archived: false)
      api_response.results.map(&:name)
    end

    def get_filtered_results_from_hubspot(body, access_token)
      api_client = connect_client(access_token)
      
      api_client.crm.contacts.search_api.do_search(
        body: body
      )
    end
  end
end