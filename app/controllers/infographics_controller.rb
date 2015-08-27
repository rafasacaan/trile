class InfographicsController < ApplicationController
  before_action :authenticate_user!
  def index
  	@circuits = Circuit.all
  	@js_file = "infographics"
  end

  def peak
  	@circuits = Circuit.all
  	@js_file = "peaks"
  end

  def sum_energy
  	@circuits = Circuit.all
  	@js_file = "sum-energy"
  end
end
