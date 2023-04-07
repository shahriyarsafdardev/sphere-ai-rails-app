# frozen_string_literal: true

class PostgresService
  class << self
    def execute_query(postgres_reference, query)
      connection = PG.connect(
        dbname: postgres_reference.db_name,
        user: postgres_reference.db_user_name,
        password: postgres_reference.password,
        host: postgres_reference.host,
        port: postgres_reference.port
      )
      result = connection.exec(query)
      connection.close
      result&.map { |row| row }
    end

    def fetch_tables_schema(postgres_reference, table_names)
      # complete schema
      # sql = "SELECT table_schema, table_name, column_name, data_type FROM information_schema.columns WHERE table_schema NOT IN ('information_schema', 'pg_catalog');"
      # tables and associations
      # sql = "SELECT conrelid::regclass AS table_name, conname, pg_get_constraintdef(c.oid) AS constraint_def FROM pg_constraint c WHERE contype = 'f' ORDER BY conrelid::regclass::text, conname;"
      # schema of some specific tables
      sql = "SELECT tc.table_name AS table, tc.column_name AS column FROM information_schema.columns AS tc LEFT JOIN information_schema.key_column_usage AS kcu ON tc.table_name = kcu.table_name AND tc.column_name = kcu.column_name LEFT JOIN information_schema.constraint_column_usage AS ccu ON kcu.constraint_name = ccu.constraint_name WHERE tc.table_name IN (#{table_names}) ORDER BY tc.table_name, tc.ordinal_position;"
      execute_query(postgres_reference, sql)&.map { |row| row }
    end

    def fetch_table_names(postgres_reference)
      sql = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"
      execute_query(postgres_reference, sql)&.map { |row| row['table_name'] }
    end
  end
end
