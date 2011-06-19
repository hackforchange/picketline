require_relative 'base'
require_relative '../lib/exception'

module PicketLine
  module Server
    class Account < Base
      set :public, File.dirname(__FILE__) + '/../static'
      set :views, File.dirname(__FILE__) + '/../views'
  
      error LoggedOutException do
        page(erb(:error, :locals => {:error => env['sinatra.error'].message}))
      end

      get '/sign-out' do
        env['rack.session']['user'] = nil
        # TODO: redirect to referrer so the user stays on the same page
        redirect '/'
      end
    
      post '/sign-up-form' do
        raise LoggedOutException.new("Passwords dont match") unless params[:password] == params[:confirm_password]
        PicketLine::DB.create_user(params)
        page(erb(:"account/thanks_for_joining"))
      end
    
      post '/login-form' do
        user = PicketLine::DB.get_user(params[:username])      
        raise LoggedOutException.new("no user") unless user
        raise LoggedOutException.new("bad password") unless params["password"] == user[:password]
        if user
          env['rack.session']['user'] = user.keep_if { |k,v| [:username, :id].include?(k) }
          redirect '/'
        else
          "fail somehow"
        end
      end

      get '/sign-up' do
        page(erb(:"account/sign_up"))
      end
    
      get '/log-in' do
        page(erb(:'account/log_in'))
      end

    end
  end
end
