class AddSchemaNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :schema_name, :string
  end
end
