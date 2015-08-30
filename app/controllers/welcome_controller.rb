class WelcomeController < ApplicationController  
  #This is the shit! You can declare functions on circuits_status.rb and share ir accross controllers. All you need to do 
  #is include the module and set a callback or use the methods directly in the functions
  include CircuitsStatus
  ########################################################################################################################
  before_action :authenticate_user!
  before_action :general_status
  ########################################################################################################################
  def index
    #This variable, selects de js file for the index view
    @js_file="welcome"
  end 

end
