class AddBinaryFieldToEvent < ActiveRecord::Migration[4.2]
  def change
    change_column :events, :uuid, :binary, limit: 64
  end
end
