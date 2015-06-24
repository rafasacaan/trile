module ApplicationHelper
	def twitterized_type(type)
		case type
		when "alert"
			"warning alert-dismissable"
		when "error"
			"danger alert-dismissable"
		when "notice"
			"info alert-dismissable"
		when "success"
			"success alert-dismissable"
		else
			type.to_s
		end
	end

	def circuit_status(status)
		case status
		when "No measures"
			 "warning"
		when "Problem"
			 "danger"
		when "Ok"
			"success"
		else
			status.to_s
		end
	end

end
