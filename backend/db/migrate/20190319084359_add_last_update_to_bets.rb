class AddLastUpdateToBets < ActiveRecord::Migration[5.2]
  def change
    add_column :bets, :last_update, :datetime
  end
end
