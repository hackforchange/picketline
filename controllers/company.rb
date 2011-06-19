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
    
    # handles search and search results
    get '/search' do
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      results = nil
      if params[:term]
        results = PicketLine::DB.company_search(params[:term])
      end
      
      erb(:'company/search', :locals => { :header => header, :head => head, :results => results })
    end
    
    get '/:name' do |n|
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      company = PicketLine::DB.get_company(n.to_s)
      
      boycotts = PicketLine::DB.get_company_boycotts(company[:id])
      
      user_boycott_reason = nil
      if env['rack.session']['user']
        user_boycott_reason = PicketLine::DB.user_boycott_reason(env['rack.session']['user'][:id], company[:id])
      end
      
      boycott_count = 0
      boycotts.each { |b| boycott_count += b[1] }
      
      erb(:'company/page', :locals => { :header => header, :head => head, :company => company, :boycotts => boycotts, :user_boycott_reason => user_boycott_reason, :boycott_count => boycott_count })
    end
    
    get '/boycott/:name' do |n|
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      company = PicketLine::DB.get_company(n.to_s)
      
      existing_reasons = PicketLine::DB.get_company_reasons(company[:id])
      
      erb(:'company/boycott', :locals => { :header => header, :head => head, :company => company, :existing_reasons => existing_reasons })
    end
    
    post '/boycott-form/:name' do |n|
      raise Exception.new("Must be logged in") unless env['rack.session']['user']
      company = PicketLine::DB.get_company(n.to_s)

      reason_id = params[:reason_id]

      if reason_id.nil? || reason_id == ""
        raise Exception.new("Please enter a reason.") unless (params[:reason] != "")
        reason = PicketLine::DB.create_reason(params[:reason])
        reason_id = reason[:id]
      end

      PicketLine::DB.create_boycott(env['rack.session']['user'][:id], company[:id], reason_id)
      redirect "/company/#{n}"
    end
    
    get '/add-subsidiaries/:name' do |n|
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      company = PicketLine::DB.get_company(n.to_s)
            
      erb(:'company/add_subsidiaries', :locals => { :header => header, :head => head, :company => company })
    end
    
    post '/add-subsidiaries-form/:name' do |n|
      raise Exception.new("Must be logged in") unless env['rack.session']['user']
      company = PicketLine::DB.get_company(n.to_s)
      
      puts company[:id]
      puts params[:corpwatch_id]
      
      PicketLine::DB.add_corpwatch(company[:id], params[:corpwatch_id])
      redirect "/company/#{n}"
    end
    
    private
    
    def page(section)
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      erb(section, :locals => { :header => header, :head => head })
    end
    
  end
end
