require 'test_helper'
class ListingMesuresTest < ActionDispatch::IntegrationTest
	setup do 
		host! 'api.example.com'
		@user = User.create!(name: "fake", email: "fake@trile.cl", password: '12345678', password_confirmation: '12345678')
		@circuit = Circuit.create!(description: 'Circuito de test', type: "Demand")
		@auth_header = "Token token=#{@user.auth_token}"
		@token = ActionController::HttpAuthentication::Token.encode_credentials(@user.auth_token)
	end
	
	teardown do 
		Measure.destroy_all
		Circuit.destroy_all 
		User.destroy_all		
	end
	# Show this example first
  	test 'valid authentication with manual token' do
    get "/circuits/#{@circuit.id}/measures", {}, { 'Accept' => Mime::JSON, 'Authorization' => @auth_header }
    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type
  	end
	# Show this after showing the #encode_credentials method
  	test 'valid authentication' do
	get "/circuits/#{@circuit.id}/measures", {}, { 'Authorization' => @token }	
    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type
  	end

  	test 'invalid authentication sets WWWW-Authenticate to Application' do
	get "/circuits/#{@circuit.id}/measures", {}, { 'Authorization' => @token + 'fake' }
    assert_equal 401, response.status
    assert_equal 'Token realm="Application"', response.headers['WWW-Authenticate']
  	end

	test 'return list of all measures form current circuit' do
	get "/circuits/#{@circuit.id}/measures", {}, { 'Accept' => Mime::JSON, 'Authorization' => @auth_header }
	assert_equal 200, response.status
	measures = JSON.parse(response.body, symbolize_names: true)
	refute_empty response.body	
	end
	
end
	