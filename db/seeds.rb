Measure.delete_all
Circuit.delete_all
User.delete_all

user = User.new
user.name = 'example'
user.email = 'example@trile.cl'
user.password = '12345678'
user.password_confirmation = '12345678'
user.save! 




circuit_list = [
				[user.id, 'Circuito seed de prueba tipo demanda', 'Demand'],
				[user.id,'Circuito seed de prueba tipo generacion', 'Generation']
			]	

circuit_list.each do |id, description, type|
measures_list_1 = [65,70]
measures_list_2 = [25,15]

	  c = Circuit.create!(user_id: id, description: description, type: type)
	  case type
	  when 'Demand'
	  	measures_list_1.each do |watts|
	  	Measure.create!(circuit_id: c.id, watts: watts)
	  end
	  when 'Generation'
	  	measures_list_2.each do |watts|
	  	Measure.create!(circuit_id: c.id, watts: watts)
	  end
	end
  end