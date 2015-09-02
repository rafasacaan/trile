class CircuitsController < ApplicationController
  include CircuitsStatus
  before_action :authenticate_user!
  before_action :set_circuit, only: [:show, :edit, :update, :destroy]
  before_action :set_circuits, only: [:index]
  before_action :set_js
  before_action :current_user
  before_action :set_type
  before_action :access_only_to_own_circuits, only: [:show]
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_circuit

  # GET /circuits
  # GET /circuits.json
  def index
  end

  # GET /circuits/1
  # GET /circuits/1.json
  def show
    #Setea el archivo con los js que se cargaran en la vista
    @js_file = "show-circuit"
  end
  # GET /circuits/new
  def new
    @circuit = type_class.new
  end
  # GET /circuits/1/edit
  def edit
    
  end
  # POST /circuits
  # POST /circuits.json
  def create
    @circuit = Circuit.new(circuit_params)
    @circuit.type = params[:type]
    
    respond_to do |format|
      if @circuit.save
        format.html { redirect_to root_path, notice: 'Circuit was successfully created.' }
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
        format.html { redirect_to root_path, notice: 'Circuit was successfully updated.' }
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

    def type
        #This sets the circuit type if it is in the params, otherwise it sets it to "Circuit" 
        Circuit.types.include?(params[:type]) ? params[:type] : "Circuit"
    end

    def set_type 
       #From the above metod, the type is attached to an instance variable.
       @type = type 
    end
    
    def type_class 
        #constantize tries to find a declared constant with the name specified in the string.
        type.constantize 
    end
   
    def set_circuit
      @circuit = type_class.find(params[:id])
    end

    def set_circuits
    #Retrieves the circuits for current user
    @circuits = type_class.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def circuit_params
      params.require(type.underscore.to_sym).permit(:user_id, :description, :type, :alarm_time)
    end
    
    #Set js file
    def set_js
    @js_file = "index-circuit"
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