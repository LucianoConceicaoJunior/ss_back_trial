class RemoveUniqueIndexFromRentals < ActiveRecord::Migration[7.0]
  def change
    remove_index :rentals, column: [:user_id, :movie_id]
    add_index :rentals, [:user_id, :movie_id], unique: false
  end
end
