json.extract! @task,
  :id, :name, :description,
  :priority,
  :dependencies,
  :milestone,
  :parent_id,
  :duration,
  :assigned_to,
  :created_at, :updated_at
