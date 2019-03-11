class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :date, null: false
      t.string :type
      t.string :match

      t.timestamps
    end
  end
end
