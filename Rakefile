require './tasks.rb'
require 'thin'

task :deploy do
  ENV['http_proxy']='proxy.mlan:3128'
  sh 'bundle check || bundle install'
end

task :restart do
  begin
    sh 'thin -C config/thin/dev.yml -f stop'
  rescue
  end
  sh 'thin -C config/thin/dev.yml start'
end

task :run => [:deploy, :restart]