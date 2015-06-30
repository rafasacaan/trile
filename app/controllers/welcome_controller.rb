class WelcomeController < ApplicationController
  before_action :authenticate_user!
  #This is the shit! You can declare functions on circuits_status.rb and share ir accross controllers. All you need to do 
  #is include the module and set a callback or use the methods directly in the functions
  include CircuitsStatus
  before_action :circuits_status, only:[:index]
  before_action :general_status, only:[:index]
  ########################################################################################################################
  
  def index
    #This variable, selects de js file for the index view
    @js_file='index'
  end 

  def general
    @js_file='general'
  end
  def buttons
    @js_file='general'
  end
  def panels  	
  end
  def calendar  	
  end
  def gallery  	
  end
  def todoList  	
  end
  
end
