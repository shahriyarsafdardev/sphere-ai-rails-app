json.paths do
  json.partial! 'api/v1/postgres_references/postgres_reference.json', collection: @postgres_references, as: :postgres_reference
end
