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
  end
end
