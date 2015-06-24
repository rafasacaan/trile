class Measure < ActiveRecord::Migration
  def change
  	create_table :measures do |t|
  	t.references :circuit, index: true
  	t.integer :watts

  	t.timestamps null: false
  	end
  	add_foreign_key :measures, :circuits
	end
end
