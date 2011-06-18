require 'rubygems'

require ::File.dirname(__FILE__) + '/controllers/server'
require ::File.dirname(__FILE__) + '/controllers/account'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'pIcKeTlInE'

map "/" do
	run PicketLine::Server
end

map "/account" do
  run PicketLine::Account
end
