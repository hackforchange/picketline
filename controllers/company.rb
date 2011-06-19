require_relative 'base'
require_relative '../lib/api/transparency_data'
require_relative '../lib/api/corpwatch'

module PicketLine
  module Server
    class Company < Base
      set :public, File.dirname(__FILE__) + '/../static'
      set :views, File.dirname(__FILE__) + '/../views'
    
      # handles search and search results
      get '/search' do
        results = params[:term] ? TransparencyData.search(params[:term]) : nil

        page(erb(:'company/search', :locals => { :results => results }))
      end
    
      get '/:name' do |slug|
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
      
        boycotts = PicketLine::DB.get_company_boycotts(company[:id])
      
        user_boycott_reason = nil
        if env['rack.session']['user']
          user_boycott_reason = PicketLine::DB.user_boycott_reason(env['rack.session']['user'][:id], company[:id])
        end
      
        boycott_count = 0
        boycotts.each { |b| boycott_count += b[1] }

        page(erb(:'company/page', :locals => { :company => company, :boycotts => boycotts, :user_boycott_reason => user_boycott_reason, :boycott_count => boycott_count, :sunlight_company => sunlight_company, :party_pie => party_pie, :subsidiaries => subsidiaries }), :company)
      end
    
      get '/boycott/:name' do |slug|
        company = PicketLine::DB.get_company(slug.to_s)
      
        existing_reasons = PicketLine::DB.get_company_reasons(company[:id])
      
        page(erb(:'company/boycott', :locals => { :company => company, :existing_reasons => existing_reasons }))
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
        company = PicketLine::DB.get_company(slug.to_s)
            
        page(erb(:'company/add_subsidiaries', :locals => { :company => company }))
      end
    
      post '/add-subsidiaries-form/:name' do |slug|
        raise Exception.new("Must be logged in") unless env['rack.session']['user']
        company = PicketLine::DB.get_company(slug.to_s)
            
        PicketLine::DB.add_corpwatch(company[:id], params[:corpwatch_id])
        redirect "/company/#{slug}"
      end
    
      get '/sunlight/:guid' do |guid|
        company = PicketLine::DB.company_by_sunlight_id(guid)

        unless company
          company = TransparencyData.get(guid)
          company[:slug] = slugify(company["name"])
          PicketLine::DB.create_company_from_sunlight(company)
        end
      
        redirect "/company/#{company[:slug]}"
      end
    
      private
    
      def slugify(name)
        name.gsub(" ", "-").gsub("_", "-").downcase
      end
    end
  end
end
