require 'sinatra/base'

module PicketLine
  class Account < Sinatra::Base
    set :public, File.dirname(__FILE__) + '/../static'
    set :views, File.dirname(__FILE__) + '/../views'

    get '/sign-out' do
      env['rack.session']['user'] = nil
      # TODO: redirect to referrer so the user stays on the same page
      redirect '/'
    end
    
    post '/sign-up-form' do
      PicketLine::DB.create_user(params)
      page :"account/thanks_for_joining"
    end
    
    post '/login-form' do
      user = PicketLine::DB.get_user(params[:username])      
      raise Exception.new("no user") unless user
      raise Exception.new("bad password") unless params["password"] == user[:password]
      if user
        env['rack.session']['user'] = user.keep_if { |k,v| [:username, :id].include?(k) }
        redirect '/'
      else
        "fail somehow"
      end
    end

    get '/sign-up' do
      page :"account/sign_up"
    end
    
    get '/log-in' do
      page :'account/log_in'
    end
    
    
    private
    
    def page(section)
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      erb(section, :locals => { :header => header, :head => head })
    end
    
  end
end
