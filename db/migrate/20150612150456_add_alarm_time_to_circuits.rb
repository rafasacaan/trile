class AddAlarmTimeToCircuits < ActiveRecord::Migration
  def change
    add_column :circuits, :alarm_time, :integer
    end
end
