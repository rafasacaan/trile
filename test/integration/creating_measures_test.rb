require 'test_helper'

class CreatingMeasuresTest < ActionDispatch::IntegrationTest
setup do 
	host! 'api.example.com'
	@user = User.create!(name: "faker", email: "faker@trile.cl", password: '12345678', password_confirmation: '12345678')
	@circuit = Circuit.create!(description: 'Circuito de test', type: "Demand")
	@auth_header = "Token token=#{@user.auth_token}"
	@token = ActionController::HttpAuthentication::Token.encode_credentials(@user.auth_token)
end

teardown do 
	Measure.destroy_all
	Circuit.destroy_all 
	User.destroy_all
end

test 'creates measures' do
		post "/circuits/#{@circuit.id}/measures",{measure:{watts: 65, circuit_id: @circuit.id}}.to_json,
		{'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s, 'Authorization' => @auth_header}		
		assert_equal 201, response.status
		assert_equal Mime::JSON, response.content_type

		measure = json(response.body)
		assert_equal api_circuit_measure_path(@circuit.id, measure[:id]), response.location	
	end
end