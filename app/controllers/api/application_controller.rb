module API
    class ApplicationController < ApplicationController
	before_action :switch_tenant
		
		private

	 def switch_tenant
		if user_signed_in?
  			Apartment::Tenant.switch!(current_user.schema_name)
		end
	end


    end
end