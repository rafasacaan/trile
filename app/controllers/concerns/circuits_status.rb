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
				flash[:error] = "Algo no esta bien con los circuitos"
			else
				@status = "OK"
				flash[:success] = "Todos los circuitos estan siendo monitoreados correctamente"
			end
		end
	end

end