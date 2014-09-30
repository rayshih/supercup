json.extract! @task,
  :id, :name, :description, :priority, :dependencies,
  :milestone,
  :parent_id,
  :created_at, :updated_at
