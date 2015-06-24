class CircuitsController < ApplicationController
  include CircuitsStatus
  before_action :set_circuit, only: [:show, :edit, :update, :destroy]
  before_action :set_js
  before_action :set_type
  before_action :access_only_to_own_circuits, only: [:show]
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_circuit

  # GET /circuits
  # GET /circuits.json
  def index
    #Rescata todos los circuitos del usuario actual
    @circuits = type_class.where(user_id: current_user.id)
    #Define el archivo js que usara el template es importante pq ahi van a dar las gon_variables para los 
    #graficos
    @js_file = "index-circuit"
  end
  # GET /circuits/1
  # GET /circuits/1.json
  def show
    #Setea el archivo con los js que se cargaran en la vista
    @js_file = "show-circuit"
  end
  # GET /circuits/newcircuit.measures.last.created_at
  def new
    @circuit = type_class.new
    @circuit.user_id = current_user.name
  end
  # GET /circuits/1/edit
  def edit
    @circuit.user_id = current_user.name
  end
  # POST /circuits
  # POST /circuits.json
  def create
    @circuit = Circuit.new(circuit_params)
    @circuit.type = params[:type]
    @circuit.user_id = current_user.id

    respond_to do |format|
      if @circuit.save
        format.html { redirect_to @circuit, notice: 'Circuit was successfully created.' }
        format.json { render :show, status: :created, location: @circuit }
      else
        format.html { render :new }
        format.json { render json: @circuit.errors, status: :unprocessable_entity }
      end
    end
  end
  # PATCH/PUT /circuits/1
  # PATCH/PUT /circuits/1.json
  def update
    respond_to do |format|
      if @circuit.update(circuit_params)
        format.html { redirect_to @circuit, notice: 'Circuit was successfully updated.' }
        format.json { render :show, status: :ok, location: @circuit }
      else
        format.html { render :edit }
        format.json { render json: @circuit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /circuits/1
  # DELETE /circuits/1.json
  def destroy
    @circuit.destroy
    respond_to do |format|
      format.html { redirect_to circuits_url, notice: 'Circuit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_type 
       @type = type 
    end
    
    def type 
        Circuit.types.include?(params[:type]) ? params[:type] : "Circuit"
    end

    def type_class 
        type.constantize 
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_circuit
      @circuit = type_class.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def circuit_params
      params.require(type.underscore.to_sym).permit(:user_id, :description, :type, :alarm_time)
    end
    
    #Set js file
    def set_js
    @js_file = "index"
    end

    def invalid_circuit
      logger.error "Attempt to access invalid circuit #{params[:id]}"
      redirect_to circuits_path, notice: 'Invalid Circuit'
    end

    def access_only_to_own_circuits
      own_circuits = set_circuits
      if own_circuits.find(params[:id])
        return true
      else
        redirect_to circuits_path, notice: 'Not your Circuit'
    end
  end
end