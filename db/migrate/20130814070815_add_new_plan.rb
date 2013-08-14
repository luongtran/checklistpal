class AddNewPlan < ActiveRecord::Migration
  def up
    if Role.where(:name => 'paid2').blank?
      Role.create({:name => "paid2", :max_savedlist => 50000, :max_connections => 50000})
    end
  end

  def down
  end
end
