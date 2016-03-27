require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task default: :spec

module TestTasks
  module_function

  def test_gemfile(gemfile, env = {})
    require 'pty'
    require 'English'
    cmd = 'bundle install --quiet && bundle exec rspec'
    Bundler.with_clean_env do
      $stderr.puts "export BUNDLE_GEMFILE=#{gemfile}"
      $stderr.puts cmd
      PTY.spawn(env.merge('BUNDLE_GEMFILE' => gemfile), cmd) do |r, _w, pid|
        begin
          r.each_line { |l| puts l }
        rescue Errno::EIO
          # Errno:EIO error means that the process has finished giving output.
          next
        ensure
          ::Process.wait pid
        end
      end
      [$CHILD_STATUS && $CHILD_STATUS.exitstatus == 0, gemfile]
    end
  end

  def gemfiles
    Dir.glob('./spec/gemfiles/*.gemfile').sort
  end

  def dbs
    %w(sqlite3 mysql2 postgresql)
  end
end

desc 'Test all Gemfiles from spec/*.gemfile'
task :test_all_gemfiles do
  statuses = TestTasks.gemfiles.map { |gemfile| TestTasks.test_gemfile(gemfile) }
  failed   = statuses.reject(&:first).map(&:last)
  if failed.empty?
    $stderr.puts "✓ Tests pass with all #{statuses.size} gemfiles"
  else
    $stderr.puts "❌  FAILING:\n#{failed * "\n"}"
    exit 1
  end
end

desc 'Test all databases x gemfiles'
task :test_all do
  statuses = TestTasks.dbs.inject({}) { |h, db|
    ENV['DB'] = db
    h.update(db => TestTasks.gemfiles.map { |gemfile|
      $stderr.puts "export DB=#{db}"
      TestTasks.test_gemfile(gemfile, 'DB' => db)
    })
  }
  failed = statuses.flat_map { |(db, db_statuses)| db_statuses.reject(&:first).map { |(_, gemfile)| [db, gemfile] } }
  if failed.empty?
    $stderr.puts "✓ Tests pass with all #{statuses.size} databases"
  else
    $stderr.puts "❌  FAILING:\n#{failed.map { |(db, gemfile)| "DB=#{db} BUNDLE_GEMFILE=#{gemfile}" } * "\n"}"
  end
end
