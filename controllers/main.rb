require 'erb'
require 'json'

require_relative 'base'
require_relative '../lib/db'

module PicketLine
  module Server
    class Main < Base
      set :public, File.dirname(__FILE__) + '/../static'
      set :views, File.dirname(__FILE__) + '/../views'
    
      get '/' do
        if env['rack.session']['user']
          page(erb(:home_logged_in))
        else
          page(erb(:home_logged_out))
        end
      end
    
      get '/user/:name' do |n|
        user = PicketLine::DB.get_user(n)
        boycotts = PicketLine::DB.get_user_boycotts(user[:id])
      
        page(erb(:user, :locals => { :user => user, :boycotts => boycotts}))
      end
    
    end
  end
end  
