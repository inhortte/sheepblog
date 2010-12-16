module Sinatra
  module CommonHelper
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

    def redirect_with_message(where, m)
      flash[:notice] = m
      redirect where
    end

    def format_time(t)
      t.strftime("%d %b, %Y, %H:%m")
    end
  end

  helpers CommonHelper
end
