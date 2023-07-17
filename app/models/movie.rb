class Movie < ApplicationRecord
  has_many :favorite_movies
  has_many :users, through: :favorite_movies

  validates :title, :available_copies, presence: true
  validates :available_copies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
  