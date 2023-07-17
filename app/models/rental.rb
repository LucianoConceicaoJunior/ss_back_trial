class Rental < ApplicationRecord
    belongs_to :user
    belongs_to :movie

    enum status: { rented: 0, delivered: 1 }
  end