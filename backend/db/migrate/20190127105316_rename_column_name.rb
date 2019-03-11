class RenameColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :type, :match_kind
  end
end
