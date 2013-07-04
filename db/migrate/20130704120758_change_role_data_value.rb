class ChangeRoleDataValue < ActiveRecord::Migration
  def change
    Role.all.each do |role|
      if role.name == "free"
        role.max_savedlist = 3
        role.max_connections = 2
      elsif role.name == "paid" 
        role.max_savedlist = 50000
        role.max_connections = 50000
      end
    end
  end

end
