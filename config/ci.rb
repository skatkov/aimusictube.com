require "tmpdir"

Dir.mktmpdir("ai-music-tube-ci") do |dir|
  ENV["RAILS_ENV"] = "test"
  ENV["DATABASE_URL"] = "sqlite3:#{dir}/tests.sqlite3"

  CI.run do
    step "Dependencies", "bundle check"
    step "Style: Ruby", "bin/rubocop"
    step "Security: Importmap vulnerability audit", "bin/importmap audit"
    step "Test schema", "bin/rails db:schema:load"
    step "Tests: Rails", "bin/rails test"

    ENV["DATABASE_URL"] = "sqlite3:#{dir}/seeds.sqlite3"
    step "Seed schema", "bin/rails db:schema:load"
    step "Tests: Reseeding preserves libraries", "bin/rails runner script/check_seeds.rb"
  end
end
