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

    def get_previous_entry(e)
      first_id = Entry.first.id
      entry = nil
      unless e.id == first_id
        (e.id - 1).downto(first_id).each do |id|
          entry = Entry.get(id)
          break if entry
        end
      end
      entry
    end

    def get_next_entry(e)
      last_id = Entry.last.id
      entry = nil
      unless e.id == last_id
        (e.id + 1).upto(last_id).each do |id|
          entry = Entry.get(id)
          break if entry
        end
      end
      entry
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

    def get_date_hash_absurd
      1990.upto(Time.now.year).inject({}) do |years, year|
        years.merge({year => months_of(year)})
      end
    end

    private

    def months_of(year)
      1.upto(12).inject({}) do |months, month|
        months.merge({month => days_of(year, month)})
      end
    end

    def days_of(year, month)
      last_day_of_the_month = (Date.parse(year.to_s + "-" + (month_to_process + 1).to_s + "-01") - 1).mday() rescue 31
      1.upto(last_day_of_the_month).inject({}) do |days, day|
        t = Time.local(year, month, day)
        days.merge({day => Entry.all(:conditions => ['created_at > ? and created_at < ?', t, t + 86400])})
      end
    end
  end

  helpers SheepHelper
end
