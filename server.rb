require 'sinatra/base'
require 'erb'

require_relative 'lib/db'

module PicketLine
  class Server < Sinatra::Base
    set :public, File.dirname(__FILE__) + '/static'
    set :views, File.dirname(__FILE__) + '/views'
    
    before do
      @user = env['rack.session']['user']
    end
    
    get '/' do
      page :index
    end
    
    get '/sign-out' do
      env['rack.session']['user'] = nil
      page :index
    end
    
    get '/sign-up' do
      page :sign_up
    end
    
    get '/log-in' do
      page :log_in
    end
    
    
    post '/sign-up-form' do
      PicketLine::DB.create_user(params)
      "signed up"
    end
    
    post '/login-form' do
      user = PicketLine::DB.get_user(params[:username])      
      raise Exception.new("no user") unless user
      raise Exception.new("bad password") unless params["password"] == user[:password]
      if user
        env['rack.session']['user'] = user.keep_if { |k,v| [:username, :id].include?(k) }
        page :index
      else
        "fail somehow"
      end
    end
    
    private
    
    def page(section)
      head = erb(:head)
      header = erb(:header, :locals => { :user => @user })
      erb(section, :locals => { :header => header, :head => head })
    end
    
  end
end  
