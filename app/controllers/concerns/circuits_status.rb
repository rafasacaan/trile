module CircuitsStatus
	extend ActiveSupport::Concern

	private 
	
	def set_circuits
		circuits = Circuit.all

	rescue ActiveRecord::RecordNotFound
		circuits = Circuit.new
	end

	def circuits_status
		@circuits = set_circuits
		@circuits.each do |c|
			#To do. Need refactor to improve performance. Measures.last could do the trick faster
			if c.measures.count == 0
				c.status = "No measures"
			else
				if (Time.now-c.measures.order(:created_at).last.created_at) > c.alarm_time*60
				c.status = "Problem"
				else
				c.status = "Ok"	
				end
			end			
		end
	end
	
	def general_status
		circuits = circuits_status
		circuits.each do |c|
			if c.status != "Ok"
				@status = "Problem"
				flash[:error] = "Check your circuits, there is something wrong"
			else
				@status = "OK"
				flash[:success] = "All circuits working correctly"
			end
		end
	end

end