class InfographicsController < ApplicationController
  def index
  	@circuits = Circuit.circuits_watts_sum(params[:date])
  	@js_file="infographics"
  end
end
