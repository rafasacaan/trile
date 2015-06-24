class SetAlarmsInCircuits < ActiveRecord::Migration
  def up
  	Circuit.all.each do |circuit|
  	if circuit.alarm_time == nil
  		circuit.alarm_time = 5
  		circuit.save!
  	end
  end
end
  
  def down
  end

end
