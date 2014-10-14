json.array!(@workers) do |worker|
  json.extract! worker, :id, :name, :order
  json.url worker_url(worker, format: :json)
end
