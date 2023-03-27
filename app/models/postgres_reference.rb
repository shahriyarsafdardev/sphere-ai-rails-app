# frozen_string_literal: true

class PostgresReference < ApplicationRecord
  belongs_to :user

  def run_query(query)
    result = GptService.query_with_postgres_reference(self, query)
    parsed_query = result.split('::')&.second&.split('::')&.first
    query_response = PostgresService.execute_query(self, parsed_query)
    { message: result, result: query_response }
  end
end
