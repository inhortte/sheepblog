require 'rubygems'
%w(sinatra rack-flash datamapper dm-mysql-adapter haml sass logger).each { |gem| require gem }
%w(common_helper/lib/common_helper.rb).each { |thurk| require thurk }
%w(user.rb entry.rb).each { |model| require "server_models/lib/#{model}" }

set :sessions, true
set :show_exceptions, false
use Rack::Flash

configure do
  set :app_file, __FILE__
  set :root, File.dirname(__FILE__)
  set :static, :true
  set :public, Proc.new { File.join(root, "public") }
  LOGGER = Logger.new("sheepblog.log")
end

DataMapper.setup(:default, 'mysql://localhost/sheepblog')

helpers Sinatra::CommonHelper

get '/sheepblog.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :"sass/sheepblog"
end

get '/' do
  redirect '/list'
end

get '/login' do
  haml :login
end

post '/login' do
  logger.info params[:username] + "   " + params[:password]
  user = authenticate(params[:username], params[:password])
  if user
    session[:id] = user.id
    redirect '/'
  else
    redirect_with_message '/login', 'That did not work, vole.'
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/list' do
  haml :list
end

helpers do
  def logger
    LOGGER
  end
end
