#YAML.load(ENV['ROLES']).each do |role|
#  Role.find_or_create_by_name({ :name => role }, :without_protection => true)
#  puts 'role: ' << role
#end
Role.create({:name => "free", :max_savedlist => 5 , :max_connections => 2})
puts "Created 'Free' role !"
Role.create({:name => "paid", :max_savedlist => 8388606 , :max_connections => 8388606 })
puts "Created 'Paid' role !"

