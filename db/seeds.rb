require_relative "catalog_seed"

CatalogSeed.new.import(JSON.parse(File.read(Rails.root.join("db/catalog.json")), allow_duplicate_key: false))
