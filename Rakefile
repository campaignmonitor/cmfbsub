desc "Start redis for development"
task :startredis do
  system 'redis-server /usr/local/etc/redis.conf'
end

desc "Start app for development"
task :startapp do
  system 'ruby -rubygems application.rb'
end

multitask :start => ['startredis', 'startapp']

task :default => :start
