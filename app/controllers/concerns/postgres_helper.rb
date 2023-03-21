module PostgresHelper
  extend ActiveSupport::Concern

  def execute_query(postgres_reference, query)
    connection = PG.connect(
      dbname: postgres_reference.db_name,
      user: postgres_reference.user_name,
      password: postgres_reference.password,
      host: postgres_reference.host,
      port: postgres_reference.port
    )
    result = connection.exec(query)
    connection.close
    result
  end
end
