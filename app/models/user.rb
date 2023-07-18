class User < ApplicationRecord
  has_many :favorite_movies
  has_many :rentals
  has_many :favorites, through: :favorite_movies, source: :movie
  has_many :rented, through: :rentals, source: :movie

  before_create :generate_api_key

  def generate_api_key
    self.api_key = SecureRandom.urlsafe_base64
  end
end