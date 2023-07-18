require 'rails_helper'

RSpec.describe Movie, type: :model do
  it 'object must be created with valid attributes' do
    movie = Movie.new
    movie.title = 'Indiana Jones And The Last Crusade'
    movie.available_copies = 0
    expect(movie).to be_valid
  end

  it 'object must not be created with empty title' do
    movie = Movie.new
    movie.title = ''
    movie.available_copies = 0
    expect(movie).not_to be_valid
  end

  it 'object must not be created with negative available_copies' do
    movie = Movie.new
    movie.title = 'Indiana Jones And The Last Crusade'
    movie.available_copies = -1
    expect(movie).not_to be_valid
  end
end
