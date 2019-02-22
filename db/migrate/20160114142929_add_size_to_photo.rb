class AddSizeToPhoto < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :width, :string
    add_column :photos, :height, :string
  end
end
