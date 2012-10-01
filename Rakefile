task :deploy do
  ENV['http_proxy']='proxy.mlan:3128'
  sh 'bundle check || bundle install'
end

task :restart do
  begin
    chdir ''
    sh 'thin -C config/thin/dev.yaml -f stop'
  rescue
  end
  sh 'thin -C config/thin/dev.yaml start'
end

task :run => [:deploy, :restart]