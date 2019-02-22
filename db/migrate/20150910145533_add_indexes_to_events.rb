class AddIndexesToEvents < ActiveRecord::Migration[4.2]
  def change
    add_index(:events, [:eid])
    add_index(:events, [:area])
    add_index(:events, [:start_time])
  end
end
