class AddAmpAutoHtml < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :description_amp, :text
  end
end
