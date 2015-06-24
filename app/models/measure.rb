class Measure < ActiveRecord::Base
	#to do: Check if counter cache would speed up the measures retrival
	belongs_to :circuit	
end