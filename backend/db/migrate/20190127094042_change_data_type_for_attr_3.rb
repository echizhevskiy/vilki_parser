class ChangeDataTypeForAttr3 < ActiveRecord::Migration[5.2]
  def self.up
    change_column :bets, :attr_3, :string
  end

  def self.down
    change_column :bets, :attr_3, :float
  end
end
