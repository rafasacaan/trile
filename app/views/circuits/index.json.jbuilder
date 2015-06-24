json.array!(@circuits) do |circuit|
  json.extract! circuit, :id, :user_id, :description, :type
  json.url circuit_url(circuit, format: :json)
end
