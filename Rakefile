namespace :db do
  desc 'Auto-migrate the database (destroys data)'
  task :migrate => :environment do
    DataMapper.auto_migrate!
  end

  desc 'Auto-upgrade the database (preserves data)'
  task :upgrade => :environment do
    DataMapper.auto_upgrade!
  end
end

desc "Start app for development"
task :start do
  system 'ruby -rubygems application.rb'
end

task :environment do
  require './environment'
end

task :default => :start