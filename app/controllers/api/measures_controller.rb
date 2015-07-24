module API
	class MeasuresController < ApplicationController
  		protect_from_forgery with: :null_session
		before_action :authenticate

		def index
			measures = Measure.where(circuit_id: params[:circuit_id])
			render json: measures, status: 200
		end

		def create
			measure = Measure.new(measure_params)
			parent_circuit = Circuit.find(params[:circuit_id])
			if measure.save
				render json: measure, status: 201, location: api_circuit_measure_path(measure.circuit_id, measure)
			else
				render json: measure.errors, status: 422
			end
		end

	protected

	def authenticate
		authenticate_token || render_unauthorized
    end

	def authenticate_token
	  authenticate_or_request_with_http_token('Application') do |token, options|
	  	@user = User.find_by(auth_token: token)
	  		if !@user.nil?
	  			change_tenant(@user.schema_name)
	  		end
	  	end
	end

	def change_tenant(tenant)
		Apartment::Tenant.switch!(tenant)
	end

    def render_unauthorized(realm=nil)
    	if realm
        self.headers['WWW-Authenticate'] = %(Token realm="#{realm.gsub(/"/, "")}")
      end
      render json: 'Bad credentials', status: 401
    end

	def measure_params
		params.require(:measure).permit(:circuit_id, :watts)
	end

	end
end