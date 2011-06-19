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
          page :home_logged_in
        else
          page :home_logged_out
        end
      end
    
      get '/user/:name' do |n|
        head = erb(:head)
        header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      
        # get the other user data
        # TODO: display user's list of boycotts with reasons
        user = PicketLine::DB.get_user(n)
        boycotts = PicketLine::DB.get_user_boycotts(user[:id])
      
        erb(:user, :locals => { :header => header, :head => head, :user => user, :boycotts => boycotts})
      end
    
    end
  end
end  
