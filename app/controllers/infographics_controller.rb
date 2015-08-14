class InfographicsController < ApplicationController
  def index
  	@circuits = Circuit.all
  	@data = Circuit.circuits_watts_sum(params[:date]).to_json
  	@js_file="infographics"
  end
end
