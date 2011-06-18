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
        @@db.run "CREATE TABLE users (`id` CHAR(32) PRIMARY KEY, `username` varchar(255) UNIQUE, `email` varchar(255) UNIQUE, `password` varchar(32), `profile` varchar(255))"
        @@db.run "CREATE TABLE companies (`id` CHAR(32) PRIMARY KEY, `name` varchar(255) UNIQUE, `profile` varchar(255))"
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
      
      def create_company(parameters)
        connect
        parameters.keep_if { |k,v| ["name"].include?(k) }
        parameters[:id] = UUID.generate(:compact)
        @@db[:companies].insert(parameters)
      end
      
      def get_company(name)
        connect
        dataset = @@db["SELECT * FROM companies WHERE name = ?", name]
        dataset.first
      end
      
    end
  end
end
