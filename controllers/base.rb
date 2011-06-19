require 'sinatra/base'

module PicketLine
  module Server
    class Base < Sinatra::Base
      def page(content, page_type=nil)
        erb(:wrapper, :locals => { :content => content , :user => env['rack.session']['user'], :page_type => page_type })
      end
    end
  end
end
