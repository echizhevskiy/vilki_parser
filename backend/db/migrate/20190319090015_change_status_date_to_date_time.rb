class ChangeStatusDateToDateTime < ActiveRecord::Migration[5.2]
  def up 
    remove_column :events, :date
    add_column :events, :date, :datetime
  end

  def down
    remove_column :events, :date
    add_column :events, :date, :datetime
  end
end
