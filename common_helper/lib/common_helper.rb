module Sinatra
  module CommonHelper
    def authenticate(username, passwd)
      user = User.get(:username => username)
      return nil if user.nil?
      return user if user.has_password?(passwd)
    end
  end

  helpers CommonHelper
end
