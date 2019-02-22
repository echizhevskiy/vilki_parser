class AddGuestTeamToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :guest_team, :string
  end
end
