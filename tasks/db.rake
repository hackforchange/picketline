require_relative '../lib/db'

desc "Create the DB schema"
task :create do
  puts "Creating the DB schema"
  PicketLine::DB.create
end
