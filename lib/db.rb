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
          primary_key :id
          unique_key :name
          unique_key :email
          String :password
          String :profile # json
        end
      end
    end
  end
end
