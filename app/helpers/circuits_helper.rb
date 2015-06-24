module CircuitsHelper
# helpers/circuits_helper.rb
# Returns a dynamic path based on the provided parameters
def sti_circuit_path(type = "circuit", circuit = nil, action = nil)
  send "#{format_sti(action, type, circuit)}_path", circuit
end

def format_sti(action, type, circuit)
  action || circuit ? "#{format_action(action)}#{type.underscore}" : "#{type.underscore.pluralize}"
end

def format_action(action)
  action ? "#{action}_" : ""
end

def format_time(time)
	time.strftime("%d %b. %Y %H:%M")
end

end
