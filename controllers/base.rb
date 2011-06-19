require 'sinatra/base'

module PicketLine
  module Server
    class Base < Sinatra::Base
      def page(section)
        head = erb(:head)
        header = erb(:header, :locals => { :user => env['rack.session']['user'] })
        erb(section, :locals => { :header => header, :head => head })
      end
    end
  end
end
