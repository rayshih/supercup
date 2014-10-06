json.array!(@leaves) do |leafe|
  json.extract! leafe, :id, :worker_id, :start_date, :end_date, :hours
  json.url leafe_url(leafe, format: :json)
end
