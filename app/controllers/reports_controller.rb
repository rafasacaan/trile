class ReportsController < ApplicationController
protect_from_forgery with: :null_session
before_action :set_circuit, only:[:today_measures,
								  :week_measures,
								  :month_measures,
								  :year_measures,
								  :specific_date_measures,
								  :last_five,
								  :circuit_type] 
before_action :set_circuits, only:[:welcome_index,
								   :labels]
before_action :authenticate_user!
	def today_measures
		render json: @circuit.today_measures(params[:variation])
	end

	def week_measures
		render json: @circuit.week_measures(params[:date])
	end

	def month_measures
		render json: @circuit.month_measures()
	end
 
	def year_measures
		render json: @circuit.year_measures()
	end

	def specific_date_measures
		date = DateTime.parse(params[:date]) 
		render json: @circuit.specific_day_measures(date, params[:variation])
	end

	def donuts
		date = DateTime.parse(params[:date]) 
		render json: Circuit.watts_sum(date, params[:type])
	end

	# def data_tool_day
	# 	date = DateTime.parse(params[:date]) || Date.now
	# 	render json: @circuit.data_tool_day(date, params[:variation])
	# end

	# def data_tool_week
	# 	date = DateTime.parse(params[:date]) || Date.now
	# 	render json: @circuit.data_tool_week(date)
	# end

	# def data_tool_month
	# 	date = DateTime.parse(params[:date]) || Date.now
	# 	render json: Circuit.data_tool_month(date)
	# end

	# def data_tool_year
	# 	date = DateTime.parse(params[:date]) || Date.now
	# 	render json: @circuit.data_tool_year(date)
	# end

	def welcome_index
		render json: @circuits
	end

	def last_five
		render json: @circuit.last_five_measures
	end

	def circuit_type
		render json: @circuit.type.to_json
	end

	def infograph
		render json: Circuit.watts_sum(params[:date])
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
		@circuits = Circuit.all.includes(:measures)
		if @circuits.count === 0
		render json: {}	
		end
	end

	def circuit_params
      params.require(type.underscore.to_sym).permit(:date, :type)
    end	

end