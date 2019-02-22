class CreateCities < ActiveRecord::Migration[4.2]
  def change
    create_table :cities do |t|
      t.string :name, null: false, index: true, unique: true
      t.references :area, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
