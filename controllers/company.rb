require 'sinatra/base'

module PicketLine
  class Company < Sinatra::Base
    set :public, File.dirname(__FILE__) + '/../static'
    set :views, File.dirname(__FILE__) + '/../views'

    get '/create' do
      page(:'company/create')
    end
    
    post '/create-form' do
      PicketLine::DB.create_company(params)
      redirect "/company/#{params[:name]}"
    end
    
    get '/:name' do |n|
      head = erb(:head)
      header = erb(:header, :locals => { :user => @user })
      company = PicketLine::DB.get_company(n.to_s)
      erb(:'company/page', :locals => { :header => header, :head => head, :company => company })
    end
    
    private
    
    def page(section)
      head = erb(:head)
      header = erb(:header, :locals => { :user => @user })
      erb(section, :locals => { :header => header, :head => head })
    end
    
  end
end
