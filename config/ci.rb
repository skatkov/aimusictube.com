require "tmpdir"

Dir.mktmpdir("ai-music-tube-ci") do |dir|
  ENV["RAILS_ENV"] = "test"

  CI.run do
    step "Dependencies", "bundle check"
    step "Style: Standard Ruby", "bundle exec standardrb --no-fix"
    step "Quality: Reek", "bundle exec reek ."
    step "Quality: Rubydex", "bundle exec ruby script/check_rubydex.rb"
    step "Security: Importmap vulnerability audit", "bin/importmap audit"
    ENV["DATABASE_URL"] = "sqlite3:#{dir}/seeds.sqlite3"
    step "Seed schema", "bin/rails db:schema:load"
    step "Catalog: Validate JSON and check reseeding preserves libraries", "bin/rails runner script/check_seeds.rb"

    ENV["DATABASE_URL"] = "sqlite3:#{dir}/tests.sqlite3"
    step "Test schema", "bin/rails db:schema:load"
    step "Tests: Minitest and SimpleCov", "bin/rails test"
  end
end
