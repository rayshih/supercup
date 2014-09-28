class AddMilestoneToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :milestone, :integer
  end
end
