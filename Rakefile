require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task default: :spec

desc 'Test all Gemfiles from spec/*.gemfile'
task :test_all_gemfiles do
  require 'pty'
  require 'shellwords'
  require 'English'
  cmd      = 'bundle update --quiet && bundle exec rake --trace'
  statuses = Dir.glob('./spec/gemfiles/*.gemfile').sort.map do |gemfile|
    Bundler.with_clean_env do
      env = {'BUNDLE_GEMFILE' => gemfile}
      $stderr.puts "Testing #{File.basename(gemfile)}:"
      $stderr.puts "  export BUNDLE_GEMFILE=#{gemfile}"
      $stderr.puts "  #{cmd}"
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
      [$CHILD_STATUS && $CHILD_STATUS.exitstatus == 0, gemfile]
    end
  end
  failed   = statuses.reject(&:first).map(&:last)
  if failed.empty?
    $stderr.puts "✓ Tests pass with all #{statuses.size} gemfiles"
  else
    $stderr.puts "❌ FAILING #{failed * "\n"}"
    exit 1
  end
end
