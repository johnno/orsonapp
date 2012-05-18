class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :user_id
      t.string :state, :default => 'Defined'
      t.string :rally_task_id
      t.timestamps
    end
  end
end
