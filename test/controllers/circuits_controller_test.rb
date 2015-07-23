require 'test_helper'

class CircuitsControllerTest < ActionController::TestCase
  setup do
    @circuit = circuits(:one)
    sign_in users(:one)
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
