# encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'sass'
require 'haml'
require 'sinatra/reloader'
require './lib/auth.rb'

set :root, File.dirname(__FILE__)
set :public_folder => File.join(File.dirname(__FILE__), 'static')
set :views, File.join(File.dirname(__FILE__), 'templates')
set :sass, :views => File.join(File.dirname(__FILE__), 'static/sass')
set :environment => :development


enable :sessions

helpers do
  def authorized?
    session[:auth] == 'Okay'
  end
end

get '/' do
  redirect to '/auth/login' unless authorized?
  @mail = session[:mail] || 'Not logged in'
  haml :index
end

post '/tasks/add' do
  File.open('tasklist.tsk','a', :encoding => 'UTF-8'){|f| f.write("#{@params[:task]}\n---\n")}
  halt 200
end

get '/tasks/show' do
  @tasks = load 'tasklist.tsk'
  haml :tasks_show
end

post '/tasks/del/:id' do
  @tasks = load 'tasklist.tsk'
  @tasks.delete_at @params[:id].to_i
  save 'tasklist.tsk', @tasks
  halt 200
end

post '/tasks/inline_edit/:id' do
  @rel = @params[:id]
  haml :tasks_inline_edit
end

post '/tasks/save/:id' do
  @tasks = load 'tasklist.tsk'
  @tasks[@params[:id].to_i] = @params[:body]
  save 'tasklist.tsk', @tasks
  halt 200
end

get '/css/:file.css' do
  sass @params[:file].to_sym
end

get '/delegates/show' do
  @delegates = load 'delegates.tsk'
  haml :delegates_show
end

post '/delegates/del/:id' do
  @delegates = load 'delegates.tsk'
  @delegates.delete_at @params[:id].to_i
  save 'delegates.tsk', @delegates
  halt 200
end

post '/delegates/add' do
  File.open('delegates.tsk', 'a', :encoding => 'UTF-8'){|f| f.write(@params[:value] + "\n---\n")}
  halt 200
end

def load(name)
  File.open(name, :encoding => 'UTF-8'){|f| f.read.split "\n---\n"}
end

def save(name, entries)
  if entries.length > 0
    File.open(name, 'w', :encoding => 'UTF-8' ){|f| f.write(entries.join("\n---\n") + "\n---\n")}
  else
    File.open(name, 'w', :encoding => 'UTF-8').write('')
  end
end