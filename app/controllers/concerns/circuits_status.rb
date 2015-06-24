module CircuitsStatus
	extend ActiveSupport::Concern

	private 

	def set_circuits
		circuits = current_user.circuits
	rescue ActiveRecord::RecordNotFound
		circuits = Circuit.new
	end

	def circuits_status
		@circuits = set_circuits
		@circuits.each do |c|
			if c.measures.count == 0
				c.status = "No measures"
			else
				if (Time.now-c.measures.last.created_at) > c.alarm_time*60
					c.status = "Problem"
				else
				c.status = "ok"	
				end
			end			
		end
	end
	
end