if ENV["SIMPLECOV"] == "1" && !defined?(Mutant)
  require "simplecov"
  SimpleCov.start
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/strict"

module ActiveSupport
  class TestCase
    # Keep the per-test coverage map in one process.
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
