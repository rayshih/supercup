json.extract! @task,
  :id, :name, :description,
  :priority,
  :dependencies,
  :milestone,
  :parent_id,
  :duration,
  :created_at, :updated_at
