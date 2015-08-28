class InfographicsController < ApplicationController
  include CircuitsStatus
  ########################################################################################################################
  before_action :authenticate_user!
  before_action :set_circuits
  before_action :general_status
  ########################################################################################################################
  def index
  	@js_file = "infographics"
  end

  def peak
  	@js_file = "peaks"
  end

  def sum_energy
  	@js_file = "sum-energy"
  end

  private
  def set_circuits
    @circuits = Circuit.all
  end
end
