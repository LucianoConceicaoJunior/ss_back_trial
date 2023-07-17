class AddStatusToRentals < ActiveRecord::Migration[7.0]
  def change
    add_column :rentals, :status, :integer, default: 0
  end
end
