class ChangeRoleDataValue < ActiveRecord::Migration
  def change
    Role.all.each do |role|
      if role.name == "free"
        role.max_savedlist = 3
        role.max_connections = 2
      elsif role.name == "paid" 
        role.max_savedlist = 8388606
        role.max_connections = 8388606
      end
      role.save
    end
  end

end
