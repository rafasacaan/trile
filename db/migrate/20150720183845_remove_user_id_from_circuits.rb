class RemoveUserIdFromCircuits < ActiveRecord::Migration
  def change
  	remove_column :circuits, :user_id, :integer
  	remove_foreign_key :circuits, column: :users
  end
end
