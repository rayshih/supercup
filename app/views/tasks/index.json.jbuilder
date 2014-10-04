json.array!(@tasks) do |task|
  json.extract! task, :id, :name, :description,
    :priority,
    :dependencies,
    :milestone,
    :parent_id,
    :duration,
    :assigned_to
  json.url task_url(task, format: :json)
end
