# frozen_string_literal: true

require 'hubspot-api-client'
require 'faraday'
require 'json'

class GptService
  class << self
    def query_with_postgres_reference(reference, raw_query)
      table_names = PostgresService.fetch_table_names(reference)
      tables_prompt = "Process the documentation from ‘#{reference&.documentation}’ and table names from ‘#{table_names}’ to return the appropriate table names needed to process the query ‘#{raw_query}‘. Add :: before the table name and don’t add any additional information and tables"
      db_schema = PostgresService.fetch_tables_schema(reference, parsed_table_names(tables_prompt))&.to_s&.gsub('=>', ':')&.gsub('"', '')
      prompt = "Your goal is to take this text: \"#{raw_query}\" and suggest a Postgres query that will execute on a database with the following schema and answer their question: #{db_schema}. Explain your reasoning first, then include the complete query at the end of your response with :: before and after the query"
      ask_gpt(prompt)
    end

    def parsed_table_names(tables_prompt)
      ask_gpt(tables_prompt)&.scan(/::\w+/)&.map do |t|
        t[2...t.length]
      end&.map { |table| "'#{table}'" }&.join(', ')
    end

    def ask_gpt(prompt)
      response = ClientOpenAI.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.5,
        }
      )
      response.dig('choices', 0, 'message', 'content').to_s.strip
    end

    def query_with_hubspot_reference(raw_query, id)
      access_token = HubspotReference.find_by(id: id)&.hubspot_access_token
      properties = HubspotService.get_schema('Contact', access_token)
      operators = %w[EQ NEQ LT LTE GT GTE BETWEEN IN NOT_IN HAS_PROPERTY NOT_HAS_PROPERTY CONTAINS_TOKEN NOT_CONTAINS_TOKEN]
      prompt = "Please extract the filters from the user input: #{raw_query} and create a HubSpot API request body with filterGroups and filters based on the following available propertyNames: #{properties} and the following available operators: #{operators}. If the user input contains multiple filters with the AND operator, place all the filters within a single filterGroup. If the user input contains multiple filters with the OR operator, place each filter within its own filterGroup. Do not include the property names in the body."
      body_json = get_gpt_response(prompt)
      # body_json['properties'] = properties
      HubspotService.get_filtered_results_from_hubspot(body_json, access_token)
    end

    def get_gpt_response(prompt)
      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{ENV['OPENAI_ACCESS_TOKEN']}",
      }

      request_body = {
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.5,
      }
      response_json = parse_response(request_body, headers)
      body = response_json.dig('choices', 0, 'message', 'content')&.match(/```(.|\n)*```/).to_s.gsub(/```|\n/, '')
      body = body.gsub('json', '')
      JSON.parse(body)
    end

    def parse_response(request_body, headers)
      endpoint_url = 'https://api.openai.com/v1/chat/completions'
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