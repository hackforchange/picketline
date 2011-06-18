require 'sequel'

module PicketLine
  class DB
    class << self
      def connect
        @@db ||= (ENV['DATABASE_URL'] ? Sequel.connect(ENV['DATABASE_URL']) : Sequel.sqlite('/Users/andrew/development/picketline/pl.db'))
      end

      def create
        connect
        @@db.create_table :users do
          String primary_key :id
          unique_key String :username
          unique_key String :email
          String :password
          String :profile # json
        end
=begin
I'm using this create table statement instead for now.

create table users (`id` integer PRIMARY KEY AUTOINCREMENT, `username` unique_key varchar(255), `email` unique_key varchar(255), `password` varchar(30), `profile` varchar(255))
=end

      end
      
      def create_user(parameters)
        connect
        parameters.keep_if { |k,v| ["username", "password", "email"].include?(k) }
        @@db[:users].insert(parameters)
      end
      
    end
  end
end
