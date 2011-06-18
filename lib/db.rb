require 'sequel'

module PicketLine
  class DB
    class << self
      def connect
        @@db ||= (ENV['DATABASE_URL'] ? Sequel.connect(ENV['DATABASE_URL']) : Sequel.sqlite('/Users/andrew/development/picketline/pl.db'))
      end

      def create
        connect
        @@db.run "create table users (`id` integer PRIMARY KEY AUTOINCREMENT, `username` unique_key varchar(255), `email` unique_key varchar(255), `password` varchar(30), `profile` varchar(255))"
        @@db.run "create table companies (`id` integer PRIMARY KEY AUTOINCREMENT, `name` unique_key varchar(255), `profile` varchar(255))"
      end
      
      def create_user(parameters)
        connect
        parameters.keep_if { |k,v| ["username", "password", "email"].include?(k) }
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
