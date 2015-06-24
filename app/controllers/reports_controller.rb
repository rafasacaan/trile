class ReportsController < ApplicationController
before_action :set_circuit

	def today_measures
		render json: @circuit.today_measures
	end

	def week_measures
		render json: @circuit.week_measures
	end

	def month_measures
		render json: @circuit.month_measures
	end

	def year_measures
		render json: @circuit.year_measures
	end

	def specific_date_measures
		date = DateTime.parse(params[:date])
		render json: @circuit.specific_day_measures(date)
	end

	def circuit_type
		render json: @circuit.type.to_json
	end

	def set_circuit
		@circuit = Circuit.find(params[:id])
		if @circuit.measures.count === 0
		render json: {}	
		end
	end	

end