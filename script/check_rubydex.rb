require "rubydex"
require "uri"

graph = Rubydex::Graph.new
graph.index_workspace
graph.resolve

root = "#{Dir.pwd}/"
issues = graph.diagnostics.filter_map do |diagnostic|
  location = diagnostic.location
  path = URI::DEFAULT_PARSER.unescape(URI(location.uri).path)
  next unless path.start_with?(root) && !path.start_with?("#{root}vendor/")

  "#{path.delete_prefix(root)}:#{location.start_line}: #{diagnostic.message}"
end

abort issues.sort.join("\n") unless issues.empty?
puts "Rubydex: no project diagnostics"
