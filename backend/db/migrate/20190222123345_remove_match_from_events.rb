class RemoveMatchFromEvents < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :match, :string
  end
end
