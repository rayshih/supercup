class CreateLeaves < ActiveRecord::Migration
  def change
    create_table :leaves do |t|
      t.references :worker, index: true
      t.date :start_date
      t.date :end_date
      t.integer :hours

      t.timestamps
    end
  end
end
