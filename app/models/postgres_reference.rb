# frozen_string_literal: true

class PostgresReference < ApplicationRecord
  belongs_to :user

  def run_query(query)
    gpt_response = GptService.query_with_postgres_reference(self, query)
    parsed_query = gpt_response.split('::')&.second&.split('::')&.first
    query_response = PostgresService.execute_query(self, parsed_query)
    { message: gpt_response, query: parsed_query, result: query_response }
  end
end
