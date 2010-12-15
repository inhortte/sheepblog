require 'rubygems'
%w(sinatra rack-flash datamapper dm-mysql-adapter haml sass logger).each { |gem| require gem }
%w(common_helper/lib/common_helper.rb).each { |thurk| require thurk }
%w(user.rb entry.rb).each { |model| require "server_models/lib/#{model}" }

set :sessions, true
set :show_exceptions, false
use Rack::Flash

DataMapper.setup(:default, 'mysql://localhost/sheepblog')

helpers Sinatra::CommonHelper

get '/' do
  redirect '/list'
end

get '/login' do
  haml :login
end

post '/login' do
  if authenticate(params[:username], params[:password])
    redirect '/'
  else
    redirect_with_message '/login', 'That did not work, vole.'
  end
end
