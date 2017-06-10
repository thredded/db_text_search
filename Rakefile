require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task default: :spec

# Common methods for the test_all_dbs, test_all_gemfiles, and test_all Rake tasks.
module TestTasks
  module_function

  def run_all(envs, cmd = 'bundle install --quiet && bundle exec rspec', success_message:)
    statuses = envs.map { |env| run(env, cmd) }
    failed   = statuses.reject(&:first).map(&:last)
    if failed.empty?
      $stderr.puts success_message
    else
      $stderr.puts "❌  FAILING (#{failed.size}):\n#{failed.map { |env| to_bash_cmd_with_env(cmd, env) } * "\n"}"
      exit 1
    end
  end

  def run(env, cmd)
    require 'pty'
    require 'English'
    Bundler.with_clean_env do
      $stderr.puts to_bash_cmd_with_env(cmd, env)
      PTY.spawn(env, cmd) do |r, _w, pid|
        begin
          r.each_line { |l| puts l }
        rescue Errno::EIO
          # Errno:EIO error means that the process has finished giving output.
          next
        ensure
          ::Process.wait pid
        end
      end
      [$CHILD_STATUS && $CHILD_STATUS.exitstatus.zero?, env]
    end
  end

  def gemfiles
    Dir.glob('./spec/gemfiles/*.gemfile').sort
  end

  def dbs
    %w[sqlite3 mysql2 postgresql]
  end

  def to_bash_cmd_with_env(cmd, env)
    "(export #{env.map { |k, v| "#{k}=#{v}" }.join(' ')}; #{cmd})"
  end
end

desc 'Test all Gemfiles from spec/*.gemfile'
task :test_all_gemfiles do
  envs = TestTasks.gemfiles.map { |gemfile| {'BUNDLE_GEMFILE' => gemfile} }
  TestTasks.run_all envs, success_message: "✓ Tests pass with all #{envs.size} gemfiles"
end

desc 'Test all supported databases'
task :test_all_dbs do
  envs = TestTasks.dbs.map { |db| {'DB' => db} }
  TestTasks.run_all envs, 'bundle exec rspec', success_message: "✓ Tests pass with all #{envs.size} databases"
end

desc 'Test all databases x gemfiles'
task :test_all do
  dbs      = TestTasks.dbs
  gemfiles = TestTasks.gemfiles
  TestTasks.run_all dbs.flat_map { |db| gemfiles.map { |gemfile| {'DB' => db, 'BUNDLE_GEMFILE' => gemfile} } },
                    success_message: "✓ Tests pass with all #{dbs.size} databases x #{gemfiles.size} gemfiles"
end
