require 'sinatra'
require 'net/https'
require 'json'
require 'haml'
require 'sqlite3'
require 'sass'

get '/auth/login' do
  redirect to '/' if authorized?
  haml :login
end

post '/auth/check' do
  user = @params[:user]
  halt 500, 'No such user' unless ['savd'].member? user
  session[:mail] = "#{@params[:user]}@corp.badoo.com"
  halt 200, 'Ok'
end

get '/auth/get_mail' do
  session[:mail] ||= 'null'
  halt 200, session[:mail]
end

post '/auth/auth' do
  uri = URI.parse "https://verifier.login.persona.org/verify"
  http = Net::HTTP.new uri.host, uri.port
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Post.new uri.request_uri
  req.set_form_data({'assertion' => @params[:assertion], 'audience' => request.url.split('/')[0..2].join('/')})

  resp = http.request req

  out = JSON.parse(resp.body)
  if out['email'] == session[:mail] && out['status'] == 'okay'
    session[:auth] = 'Okay'
    redirect to '/'
  else
    halt 500, 'Authorization failed'
  end
end

get '/auth/logout' do
  session[:mail] = nil
  session[:auth] = nil
  redirect to '/'
end