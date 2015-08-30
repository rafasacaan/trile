#First! Switch Tenant
Apartment::Tenant.switch!("prv_6");

#Delete existing data
Measure.delete_all
Circuit.delete_all

#Circuits to be created
circuit_list = [['Demanda 1', 'Demand', 5],	['Generation 1', 'Generation', 5]]	

#Seconds difference in unix timestamp from Fri, 27 Mar 2015 16:21:37 GMT to now
interval_in_unix_timestamp = Time.now.to_i - 1438014097
beginig = 1427473297
#Measures per circuit (every 100 seconds)
number_of_measures = interval_in_unix_timestamp/100


circuit_list.each do |description, type, alarm_time|
#Create the circuit	
    c = Circuit.create!(description: description, type: type, alarm_time: alarm_time)
    puts number_of_measures
	(0..number_of_measures).each do |i|
		Measure.create!(circuit_id: c.id, watts:  Random.rand(1000), created_at: Time.at(i*100+beginig))
	end
end