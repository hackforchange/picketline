require 'sinatra/base'
require_relative '../lib/transparency_data'
require_relative '../lib/corpwatch'

module PicketLine
  class Company < Sinatra::Base
    set :public, File.dirname(__FILE__) + '/../static'
    set :views, File.dirname(__FILE__) + '/../views'
    
    # handles search and search results
    get '/search' do
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      results = nil
      if params[:term]
        results = TransparencyData.search(params[:term])
      end
      
      erb(:'company/search', :locals => { :header => header, :head => head, :results => results })
    end
    
    get '/:name' do |slug|
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      company = PicketLine::DB.get_company(slug.to_s)
      sunlight_company = TransparencyData.get(company[:sunlight_id])
      
      party_breakdown = TransparencyData.party_breakdown(company[:sunlight_id])
      party_pie = []
      party_breakdown.each do |k,v|
        party_pie << [k, v[1].to_i]
      end
      
      subsidiaries = nil
      if company[:corpwatch_id]
        subsidiaries = CorpWatch.children(company[:corpwatch_id])
      end
      puts subsidiaries
      
      boycotts = PicketLine::DB.get_company_boycotts(company[:id])
      
      user_boycott_reason = nil
      if env['rack.session']['user']
        user_boycott_reason = PicketLine::DB.user_boycott_reason(env['rack.session']['user'][:id], company[:id])
      end
      
      boycott_count = 0
      boycotts.each { |b| boycott_count += b[1] }
      
      erb(:'company/page', :locals => { :header => header, :head => head, :company => company, :boycotts => boycotts, :user_boycott_reason => user_boycott_reason, :boycott_count => boycott_count, :sunlight_company => sunlight_company, :party_pie => party_pie, :subsidiaries => subsidiaries })
    end
    
    get '/boycott/:name' do |slug|
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      company = PicketLine::DB.get_company(slug.to_s)
      
      existing_reasons = PicketLine::DB.get_company_reasons(company[:id])
      
      erb(:'company/boycott', :locals => { :header => header, :head => head, :company => company, :existing_reasons => existing_reasons })
    end
    
    post '/boycott-form/:name' do |slug|
      raise Exception.new("Must be logged in") unless env['rack.session']['user']
      company = PicketLine::DB.get_company(slug.to_s)

      reason_id = params[:reason_id]

      if reason_id.nil? || reason_id == ""
        raise Exception.new("Please enter a reason.") unless (params[:reason] != "")
        reason = PicketLine::DB.create_reason(params[:reason])
        reason_id = reason[:id]
      end

      PicketLine::DB.create_boycott(env['rack.session']['user'][:id], company[:id], reason_id)
      redirect "/company/#{slug}"
    end
    
    get '/add-subsidiaries/:name' do |slug|
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      company = PicketLine::DB.get_company(slug.to_s)
            
      erb(:'company/add_subsidiaries', :locals => { :header => header, :head => head, :company => company })
    end
    
    post '/add-subsidiaries-form/:name' do |slug|
      raise Exception.new("Must be logged in") unless env['rack.session']['user']
      company = PicketLine::DB.get_company(slug.to_s)
            
      PicketLine::DB.add_corpwatch(company[:id], params[:corpwatch_id])
      redirect "/company/#{slug}"
    end
    
    get '/sunlight/:guid' do |guid|
      company = PicketLine::DB.sunlight_company(guid)
      
      unless company
        company = TransparencyData.get(guid)
        company["slug"] = slugify(company["name"])
        PicketLine::DB.create_company_from_sunlight(company)
      end
      
      redirect "/company/#{company['slug']}"
    end
    
    private
    
    def slugify(name)
      name.gsub(" ", "-").gsub("_", "-").downcase
    end
    
    def page(section)
      head = erb(:head)
      header = erb(:header, :locals => { :user => env['rack.session']['user'] })
      erb(section, :locals => { :header => header, :head => head })
    end
    
  end
end
