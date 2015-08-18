class InfographicsController < ApplicationController
  def index
  	@circuits = Circuit.all()
  	@js_file="infographics"
  end
end
