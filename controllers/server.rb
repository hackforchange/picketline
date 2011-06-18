require 'sinatra/base'
require 'erb'

require_relative '../lib/db'

module PicketLine
  class Server < Sinatra::Base
    set :public, File.dirname(__FILE__) + '/../static'
    set :views, File.dirname(__FILE__) + '/../views'
    
    get '/' do
      page :home_logged_out
    end
    
    get '/user/:name' do |n|
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      
      # get the other user data
      # TODO: display user's list of boycotts with reasons
      user = PicketLine::DB.get_user(n)
      erb(:user, :locals => { :header => header, :head => head, :user => user})
    end
    
    private
    
    def page(section)
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      erb(section, :locals => { :header => header, :head => head })
    end
    
  end
end  
