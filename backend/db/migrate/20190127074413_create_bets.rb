class CreateBets < ActiveRecord::Migration[5.2]
  def change
    create_table :bets do |t|
      t.integer :event_id, null: false
      t.string :office, null: false
      t.string :kind, null: false
      t.float :ratio
      t.float :attr_1
      t.float :attr_2
      t.float :attr_3
      t.float :attr_4
      t.float :attr_5

      t.timestamps
    end
  end
end
