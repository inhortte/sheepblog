require 'date'

module Sinatra
  module SheepHelper
    def authenticate(username, passwd)
      user = User.first(:username => username)
      return nil if user.nil?
      return user if user.has_password?(passwd)
    end

    def get_user
      if session[:id]
        return User.get(session[:id])
      end
    end

    def just_date(t)
      Time.local(t.year, t.month, t.day)
    end

    # get previous or next entry
    def get_pn_entry(e, pn = :previous)
      entries = Entry.all(:order => :created_at.asc)
      index = entries.index(e)
      entry = nil
      unless index == (pn == :previous ? 0 : entries.size - 1)
        (index.send(pn == :previous ? :- : :+, 1)).send(pn == :previous ? :downto : :upto, pn == :previous ? 0 : entries.size - 1).each do |i|
          entry = entries[i] if (just_date entries[i].created_at) != (just_date e.created_at)
          break if entry
        end
      end
      entry
    end

    def get_previous_entry(e)
      get_pn_entry(e, :previous)
    end

    def get_next_entry(e)
      get_pn_entry(e, :next)
    end

    def truncated(text)
      html = from_blue_cloth(text)
      html[0..(html.size < 271 ? html.size : 271)] + (html.size < 271 ? '' : '...')
    end

    def redirect_with_message(where, m)
      flash[:notice] = m
      redirect where
    end

    def format_time(t)
      t.strftime("%d %b, %Y, %H:%m")
    end

    def mysql_time(t)
      t.strftime("%Y-%m-%d %H:%M:%S")
    end

    def turnip_link_from_time(e, prefix = 'turnip')
      "/#{prefix}/#{e.created_at.year}/#{e.created_at.month}/#{e.created_at.day}"
    end

    def day_id(e, prefix = 'day')
      "#{prefix}#{e.created_at.year}#{"%02d" % e.created_at.month}#{"%02d" % e.created_at.day}"
    end

    def from_blue_cloth(bc)
      BlueCloth.new(bc).to_html
    end

    def haml_partial(name, options = {})
      item_name = name.to_sym
      counter_name = "#{name}_counter".to_sym
      if collection = options.delete(:collection)
        collection.enum_for(:each_with_index).collect do |item,index|
          haml_partial name, options.merge(:locals => {item_name => item, counter_name => index+1})
        end.join
      elsif object = options.delete(:object)
        haml_partial name, options.merge(:locals => {item_name => object, counter_name => nil})
      else
        haml "#{name}".to_sym, options.merge(:layout => false)
      end
    end

    def get_date_hash
      Entry.all(:order => :created_at.asc).inject({}) do |es, e|
        year = e.created_at.year
        month = e.created_at.month
        day = e.created_at.day
        if es[year]
          if es[year][month]
            if es[year][month][day]
              es[year][month][day].push e
              es
            else
              es[year][month] = es[year][month].merge({day => [ e ]})
              es
            end
          else
            es[year] = es[year].merge({month => {day => [ e ]}})
            es
          end
        else
          es = es.merge({year => {month => {day => [ e ]}}})
          es
        end
      end
    end
  end

  helpers SheepHelper
end
