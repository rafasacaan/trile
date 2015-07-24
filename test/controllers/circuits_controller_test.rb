require 'test_helper'

class CircuitsControllerTest < ActionController::TestCase
  setup do
    @user = User.create!(name: "faker", email: "faker@trile.cl", password: '12345678', password_confirmation: '12345678')
    Apartment::Tenant.switch!(@user.schema_name)
    @circuit = Circuit.create!(description: 'Circuito de test', type: "Demand")
    sign_in @user 
 end

  teardown do 
    Circuit.destroy_all 
    User.destroy_all
  end


  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:circuits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create circuit" do
    assert_difference('Circuit.count') do
      post :create, circuit: { description: @circuit.description, type: @circuit.type}
    end

    assert_redirected_to circuit_path(assigns(:circuit))
  end

  test "should show circuit" do
    get :show, id: @circuit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @circuit
    assert_response :success
  end

  test "should update circuit" do
    patch :update, id: @circuit, circuit: { description: @circuit.description, type: @circuit.type }
    assert_redirected_to circuit_path(assigns(:circuit))
  end

  test "should destroy circuit" do
    assert_difference('Circuit.count', -1) do
      delete :destroy, id: @circuit
    end

    assert_redirected_to circuits_path
  end
end
