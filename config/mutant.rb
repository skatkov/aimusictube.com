require "fileutils"
require "tmpdir"

worker_databases = Dir.mktmpdir("ai-music-tube-mutant")
parent_pid = Process.pid
at_exit { FileUtils.remove_entry(worker_databases) if Process.pid == parent_pid }

template_database = nil
hooks.register(:setup_integration_post) do
  pool = ActiveRecord::Base.connection_pool
  template_database = File.expand_path(pool.db_config.database)
  pool.disconnect!
end

isolate_database = lambda do |index:|
  database = File.join(worker_databases, "#{Process.pid}-#{index}.sqlite3")
  FileUtils.cp(template_database, database)
  ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: database)
end

hooks.register(:test_worker_process_start, &isolate_database)
hooks.register(:mutation_worker_process_start, &isolate_database)
