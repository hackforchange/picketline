require 'sinatra/base'
require 'erb'

module PicketLine
  class Server < Sinatra::Base
    set :public, File.dirname(__FILE__) + '/static'
    set :views, File.dirname(__FILE__) + '/views'
    
    get '/' do
      erb :index
    end
  
  end
end  
