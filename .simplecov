SimpleCov.load_profile "rails"
SimpleCov.track_tests
SimpleCov.cover "{app,lib}/**/*.{rb,rake}"

SimpleCov.coverage :line, minimum: 100 do
  minimum 100, per: :file
end

SimpleCov.coverage :branch, minimum: 100 do
  minimum 100, per: :file
  ignore :implicit_else, :eval_generated
end
