module TasksHelper

def dashgum_list_type(type)
	case type
	when "Generation"
		"success"
	when "Demand"
		"danger"
	else
		type.to_s
	end
end

def dashgum_badge_type(type)
	case type
	when "Generation"
		"bg-success"
	when "Demand"
		"bg-important"
	else
		type.to_s
	end
end

end


