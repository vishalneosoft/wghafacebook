class AddEventIndex < ActiveRecord::Migration[4.2]
  def change
    add_index(:events, [:uuid], unique: true)
  end
end
