json.array!(@circuit.week_measures) do |measure|
  json.extract! measure, :id, :watts, :created_at
end
