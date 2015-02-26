require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

task :test => :spec
task :default => :spec

namespace :db do
  desc "Auto-migrate the database (destroys data)"
  task :migrate => :environment do
    DataMapper.auto_migrate!
  end

  desc "Auto-upgrade the database (preserves data)"
  task :upgrade => :environment do
    DataMapper.auto_upgrade!
  end
end

desc "Start app for development"
task :start do
  system "foreman start"
end

task :environment do
  require "./environment"
end
