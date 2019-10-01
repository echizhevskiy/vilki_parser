class CreateArbitrations < ActiveRecord::Migration[5.2]
  def change
    create_table :arbitrations do |t|
      t.integer :event_id
      t.integer :first_bet_id
      t.integer :second_bet_id
      t.integer :third_bet_id
      t.float :ratio

      t.timestamps
    end
  end
end
