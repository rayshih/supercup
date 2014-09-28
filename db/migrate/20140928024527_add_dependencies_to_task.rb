class AddDependenciesToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :dependencies, :text
  end
end
