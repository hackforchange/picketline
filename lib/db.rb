require 'sequel'
require 'uuid'

module PicketLine
  class DB
    class << self
      def connect
        @@db ||= (ENV['DATABASE_URL'] ? Sequel.connect(ENV['DATABASE_URL']) : Sequel.sqlite('/Users/andrew/development/picketline/pl.db'))
      end

      def create
        connect
        @@db.run "DROP TABLE IF EXISTS users"
        @@db.run "DROP TABLE IF EXISTS companies"
        @@db.run "DROP TABLE IF EXISTS boycotts"
        @@db.run "DROP TABLE IF EXISTS reasons"
        
        @@db.run "CREATE TABLE users (id CHAR(32) PRIMARY KEY, username varchar(255) UNIQUE, email varchar(255) UNIQUE, password varchar(32), profile varchar(255))"
        @@db.run "CREATE TABLE companies (id CHAR(32) PRIMARY KEY, slug varchar(255) UNIQUE NOT NULL, name varchar(255) UNIQUE NOT NULL, profile varchar(255), corpwatch_id CHAR(32), sunlight_id CHAR(32) NOT NULL)"
        @@db.run "CREATE TABLE boycotts (user_id CHAR(32), reason_id CHAR(32), company_id CHAR(32))"
        @@db.run "CREATE INDEX index_boycott_user ON boycotts (user_id)"
        @@db.run "CREATE INDEX index_boycott_company ON boycotts (company_id)"
        @@db.run "CREATE TABLE reasons (id CHAR(32) UNIQUE, reason varchar(255))"
      end
      
      def create_user(parameters)
        connect
        parameters.keep_if { |k,v| ["username", "password", "email"].include?(k) }
        parameters[:id] = UUID.generate(:compact)
        @@db[:users].insert(parameters)
      end
      
      def get_user(username)
        connect
        dataset = @@db["SELECT * FROM users WHERE username = ?", username]
        dataset.first
      end
      
      def create_company_from_sunlight(parameters)
        connect
        parameters["sunlight_id"] = parameters["id"]
        parameters.keep_if { |k,v| ["name", :slug, "sunlight_id"].include?(k) }
        parameters[:id] = UUID.generate(:compact)
        parameters = corpwatch_hack(parameters)
        
        @@db[:companies].insert(parameters)
      end
      
      def corpwatch_hack(c)
        if c[:slug] == "wal-mart-stores"
          c["corpwatch_id"] = "cw_1901"
        elsif c[:slug] == "safeway-inc"
          c["corpwatch_id"] = "cw_1572"
        end
        c
      end
      
      def get_company(slug)
        connect
        dataset = @@db["SELECT * FROM companies WHERE slug = ?", slug]
        dataset.first
      end
      
      def create_boycott(user_id, company_id, reason_id)
        connect
        hash = {}
        hash[:user_id] = user_id
        hash[:company_id] = company_id
        hash[:reason_id] = reason_id
        @@db[:boycotts].insert(hash)
      end
      
      def create_reason(reason)
        connect
        hash = {:reason => reason}
        hash[:id] = UUID.generate(:compact)
        @@db[:reasons].insert(hash)
        hash
      end
      
      # get a list of company names and reasons for a user
      def get_user_boycotts(user_id)
        connect
        boycotts = @@db["SELECT * FROM boycotts WHERE user_id = ?", user_id]
        boycotts.collect do |b|
          hash = {}
          hash[:reason] = @@db["SELECT * FROM reasons WHERE id = ?", b[:reason_id]].first[:reason]
          company = @@db["SELECT * FROM companies WHERE id = ?", b[:company_id]].first
          hash[:company_name] = company[:name]
          hash[:company_slug] = company[:slug]
          hash
        end
      end
      
      # get a list of boycott reasons with number of users who boycott for that reason
      def get_company_boycotts(company_id)
        connect
        boycotts = @@db["SELECT * FROM boycotts WHERE company_id = ?", company_id]
        reason_count = {}
        boycotts.each do |b|
          reason_count[b[:reason_id]] ||= 0
          reason_count[b[:reason_id]] += 1
        end

        reasons = []
        reason_count.each do |reason_id,count|
          reason = @@db["SELECT * FROM reasons WHERE id = ?", reason_id].first[:reason]
          reasons << [reason, count]
        end
        
        reasons
      end
      
      # get all the reasons that people are boycotting this company
      def get_company_reasons(company_id)
        connect
        boycotts = @@db["SELECT * FROM boycotts WHERE company_id = ?", company_id]
        reason_ids = boycotts.collect { |b| b[:reason_id] }.uniq

        reason_ids.collect do |id|
          @@db["SELECT * FROM reasons WHERE id = ?", id].first
        end
      end
      
      def user_boycott_reason(user_id, company_id)
        connect
        boycott = @@db["SELECT * FROM boycotts WHERE company_id = ? AND user_id = ?", company_id, user_id].first
        return nil unless boycott
        
        @@db["SELECT * FROM reasons WHERE id = ?", boycott[:reason_id]].first[:reason]
      end
      
      def company_search(term)
        connect
        # TODO: sequel injection exploit
        @@db[:companies].filter( :name.like("%#{term}%") )
      end
      
      def add_corpwatch(company_id, corpwatch_id)
        connect
        @@db[:companies].where({:id => company_id}).update({:corpwatch_id => corpwatch_id})
      end
      
      def company_by_sunlight_id(guid)
        connect
        @@db["SELECT * FROM companies WHERE sunlight_id = ?", guid].first
      end
    end
  end
end
