class CreateCircuits < ActiveRecord::Migration
  def change
    create_table :circuits do |t|
      t.references :user, index: true
      t.text :description
      t.string :type

      t.timestamps null: false
    end
    add_foreign_key :circuits, :users
  end
end
