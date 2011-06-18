require 'sinatra/base'
require 'erb'

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
      erb :index
    end
  
  end
end  
