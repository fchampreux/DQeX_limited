# Usage: rails db:seed admin_pass=#DQAdmin01!
if ENV["admin_pass"]
  Dir[Rails.root.join('db/seeds/*.rb')].sort.each do |file|
    puts "Processing #{file.split('/').last}"
    require file
  end
else
  puts "Please provide strong Administrator password: 8 positions including at least 1 upper case letter, 1 lowercase lettre, 1 number, 1 sign (other than '_')"
end
