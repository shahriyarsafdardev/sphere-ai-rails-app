require 'hubspot-api-client'
require 'faraday'
require 'json'

class GptService
  class << self
    def query_with_postgres_reference(reference, raw_query)
      table_names = PostgresService.fetch_table_names(reference)
      tables_prompt = "Your goal is to take this text: \"#{raw_query}\" process a query and return the table names most likely used in the query. These are the table names in the database #{table_names}. Add :: before the table name and don't add any additional information"
      parsed_table_names = ask_gpt(tables_prompt)&.scan(/::\w+/)&.map do |t|
                             t[2...t.length]
                           end&.map { |table| "'#{table}'" }&.join(', ')
      db_schema = PostgresService.fetch_tables_schema(reference, parsed_table_names)
      prompt = "Your goal is to take this text: \"#{raw_query}\" and suggest a Postgres query that will execute on a database with the following schema and answer their question: #{db_schema}. Explain your reasoning first, then include the complete query at the end of your response with :: before and after the query"
      ask_gpt(prompt)
    end

    def ask_gpt(prompt)
      response = ClientOpenAI.chat(
        parameters: {
          model: 'gpt-4',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.5
        }
      )
      response.dig('choices', 0, 'message', 'content').to_s.strip
    end

    def query_with_hubspot_references(raw_query, access_token)
      api_client = HubspotService.connect_client(access_token)
      api_response = api_client.crm.properties.core_api.get_all(object_type: 'Contact', archived: false)
      properties = api_response.results.map { |r| r.name }
      @contacts = Hubspot::Contact.all({ property: properties })
      prompt = "Your goal is to take this text: \"#{raw_query}\" and provide the body to pass to search api of hubspot v3 to answer the question. use these properties to make decisions of properties name: #{properties}. Return the body which i can pass to the search api of hubspot"
      get_gpt_response(prompt)
    end

    def generate_query(prompt)
      response = ClientOpenAI.chat(
        parameters: {
          model: 'gpt-4',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.5,
        }
      )
      response.dig('choices', 0, 'message', 'content').to_s.strip
    end

    def get_gpt_response(prompt)
      openai_api_key = ENV['OPENAI_ACCESS_TOKEN']
      endpoint_url = 'https://api.openai.com/v1/chat/completions'
      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{openai_api_key}",
      }

      request_body = {
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.5,
      }
      response_json = parse_response(endpoint_url, request_body, headers)
      response_json['choices'][0]['text'].strip
    end

    def parse_response(endpoint_url, request_body, headers)
      client = Faraday.new(url: endpoint_url)
      client.options.timeout = 9999
      response = client.post do |req|
        req.headers = headers
        req.body = request_body.to_json
      end
      JSON.parse(response.body)
    end
  end
end
