require 'rubygems'

require ::File.dirname(__FILE__) + '/server'

map "/" do
	run PicketLine::Server
end
