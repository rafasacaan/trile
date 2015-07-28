class ReportsController < ApplicationController
before_action :set_circuit, except:[:index_measures, :labels, :welcome_index] 
before_action :set_circuits, only:[:index_measures, :labels, :welcome_index]


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

	def index_measures
		render json: @circuit.index_measures
	end

	def welcome_index
		render json: @circuits
	end

	def last_five
		render json: @circuit.last_five_measures
	end

	def circuit_type
		render json: @circuit.type.to_json
	end

	def labels
		a = []
		@circuits.each do |c|
		a.push(c.description) 
		end
		render json: a.to_json
	end

	private

	def set_circuit
		@circuit = Circuit.find(params[:id])
		if @circuit.measures.count === 0
		render json: {}	
		end
	end

	def set_circuits
		#A new circuit object is created empty as a placeholder for data
		@circuit = Circuit.new
		#The circuits of the current tenant are retrived
		@circuits = Circuit.all
		if @circuits.count === 0
		render json: {}	
		end
	end	

end