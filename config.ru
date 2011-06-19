require 'rubygems'

require ::File.dirname(__FILE__) + '/controllers/server'
require ::File.dirname(__FILE__) + '/controllers/account'
require ::File.dirname(__FILE__) + '/controllers/company'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'pIcKeTlInE'

map "/" do
	run PicketLine::Server::Main
end

map "/account" do
  run PicketLine::Server::Account
end

map "/company" do
  run PicketLine::Server::Company
end
