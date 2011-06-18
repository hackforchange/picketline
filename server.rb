require 'sinatra/base'
require 'erb'

require_relative 'lib/db'

module PicketLine
  class Server < Sinatra::Base
    set :public, File.dirname(__FILE__) + '/static'
    set :views, File.dirname(__FILE__) + '/views'
    
    before do
      # TODO: check if the user has a session cookie and set their
      # user_name and id here.
      @user = { :name => "andrew", :id => 1 }
    end
    
    get '/' do
      puts @user
      page :index
    end
    
    private
    
    def page(section)
      head = erb(:head)
      header = erb(:header)
      erb(section, :locals => { :header => header, :head => head })
    end
    
  end
end  
