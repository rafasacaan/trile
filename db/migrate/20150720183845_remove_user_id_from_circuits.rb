class RemoveUserIdFromCircuits < ActiveRecord::Migration
  def change
  	remove_column :circuits, :user_id
  end
end
