require 'rubygems'
%w(sinatra rack-flash datamapper dm-mysql-adapter haml sass logger).each { |gem| require gem }
%w(sheep_helper/lib/sheep_helper.rb).each { |thurk| require thurk }
%w(user.rb entry.rb).each { |model| require "server_models/lib/#{model}" }

require 'sinatra/reloader' if development?

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

helpers Sinatra::SheepHelper

before do
  if request.path =~ /(turnip|rutabaga|new|login)/
    @date_hash = get_date_hash
  else
    @date_hash = {}
  end
end

get '/sheepblog.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :"sass/sheepblog"
end

get '/' do
  redirect '/rutabaga'
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

get '/rutabaga' do
  haml :recent
end

get '/new' do
  if !get_user
    redirect '/'
  else
    haml :new
  end
end

get %r{/(ajax|turnip)/([\d]+)/([\d]+)/([\d]+)} do
  t = Time.local(params[:captures][1].to_i,
                 params[:captures][2].to_i,
                 params[:captures][3].to_i)
  @entries = Entry.all(:conditions => [ 'created_at > ? and created_at < ?',
                                        t, t + 86400 ],
                       :order => [ :created_at.asc ])
  flash[:notice] = "Nothing is here, vole." if @entries.empty?
  if !@entries.empty?
    @previous = get_previous_entry(@entries.first)
    @next     = get_next_entry(@entries.last)
  end
  
  if(params[:captures][0] == 'ajax')
    haml :day, :layout => false
  else
    haml :day
  end
end

helpers do
  def logger
    LOGGER
  end
end

