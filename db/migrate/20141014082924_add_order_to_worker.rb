class AddOrderToWorker < ActiveRecord::Migration
  def change
    add_column :workers, :order, :integer
  end
end
