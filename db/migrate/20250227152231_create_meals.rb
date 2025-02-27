class CreateMeals < ActiveRecord::Migration[7.1]
  def change
    create_table :meals do |t|
      t.text :description
      t.integer :fat
      t.integer :carbs
      t.integer :protein
      t.integer :total_calories

      t.timestamps
    end
  end
end
