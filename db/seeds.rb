require_relative "catalog_seed"

CatalogSeed.new.import(JSON.load_file(Rails.root.join("db/catalog.json")))
