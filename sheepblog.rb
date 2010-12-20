require 'rubygems'
%w(sinatra rack-flash datamapper dm-mysql-adapter haml sass logger bluecloth).each { |gem| require gem }
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
    redirect_with_message '/login', 'You are not logged in, vole.'
  else
    haml :new
  end
end

post '/new' do
  if !get_user
    redirect_with_message '/login', 'You are not loged in, vole.'
  else
    m = %r{^\s*(\d\d\d\d)[-/]?(\d{1,2})[-/]?(\d{1,2})\s*$}.match(params[:arbitrary_date])
    timestamp = if m
                  mysql_time Time.local(m[1], m[2], m[3], 23, 59, 59) rescue mbysql_time(Time.now)
                end
    entry = Entry.new(:subject => params[:subject],
                      :entry => params[:entry])
    if entry.save
      if timestamp
        entry.created_at = timestamp
        entry.save
      end
      redirect turnip_link_from_time(entry)
    else
      flash[:notice] = 'Problems:'
      entry.errors.each { |error|
        flash[:notice] += "<br />" + error[0]
      }
      redirect '/new'
    end
  end
end

get '/upravit/:id' do
  @entry = Entry.get(params[:id])
  if !get_user || !@entry
    "Huh?" # Perhaps do something else, but... well, why, really?
  else
    haml :edit, :layout => false
  end
end

post '/upravit' do
  entry = Entry.get(params[:id])
  if !get_user || !entry
    "You screwed up, vole."
  else
    timestamp = mysql_time Time.parse(params[:arbitrary_date]) rescue mysql_time Time.now
    if entry.update(:subject => params[:subject],
                    :entry => params[:entry],
                    :created_at => timestamp)
      redirect turnip_link_from_time(entry)
    else
      "Huh?"
#      flash[:notice] = 'Problems:'
#      entry.errors.each { |error|
#        flash[:notice] += "<br />" + error[0]
#      }
#      redirect '/new'
    end
  end
end

# Called via Ajax. The return value is not used.
get '/smazat/:id' do
  if !get_user
    # Do nothing.
  else
    e = Entry.get(params[:id])
    e.destroy if e
  end
end

# This fetches all entries from the day the id'd entry is from.
# I am assuming this will only be called by clicking 'revert' and by Ajax.
get '/zobrazit/:id' do
  @entry = Entry.get(params[:id])
  if !@entry
    "Huh?"
  else
    t = Time.parse(@entry.created_at.strftime("%Y-%m-%d"))
    @entries = Entry.all(:conditions => [ 'created_at >= ? and created_at < ?',
                                          t, t + 86400 ],
                         :order => [ :created_at.asc ])
    if !@entries.empty?
      @previous = get_previous_entry(@entries.first)
      @next     = get_next_entry(@entries.last)
    end
    haml :day, :layout => false
  end
end

# Refactor this and the previous.
get %r{/(ajax|turnip)/([\d]+)/([\d]+)/([\d]+)} do
  t = Time.local(params[:captures][1].to_i,
                 params[:captures][2].to_i,
                 params[:captures][3].to_i)
  @entries = Entry.all(:conditions => [ 'created_at >= ? and created_at < ?',
                                        t, t + 86400 ],
                       :order => [ :created_at.asc ])
  flash[:notice] = "Nothing is here, vole." if @entries.empty? && params[:captures][0] == 'turnip'
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

