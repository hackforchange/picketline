require 'rubygems'

require ::File.dirname(__FILE__) + '/server'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'pIcKeTlInE'

map "/" do
	run PicketLine::Server
end
