require 'rails_helper'

RSpec.describe "Movies", type: :request do

  before(:example) do
    @user = User.create! name: 'User1'
  end

  describe "authentication" do
    it "should fail when no API Key provided" do
      get ("#{movies_path}")
      expect(response).to have_http_status(401)
    end

    it "should fail with invalid API Key" do
      get ("#{movies_path}?api_key=1234")
      expect(response).to have_http_status(401)
    end
  end

  describe "GET /movies" do
    it "should return movies list" do
      create_movie
      get ("#{movies_path}?api_key=#{@user.api_key}")
      expect(response).to have_http_status(200)
      expect(response.body).to eq(Movie.all.to_json)
    end
  end

  describe "GET /movies/recommendations" do
    it "should return recommendations list" do
      create_movie
      set_favorites
      set_rented_movies
      get ("#{recommendations_movies_path}?api_key=#{@user.api_key}")
      expect(response).to have_http_status(200)
      expect(response.body).to eq({ based_on_favorites: [Movie.last], based_on_rented: [Movie.third] }.to_json)
    end
  end

  describe "GET /movies/user_rented_movies" do
    it "should return user rented movies list" do
      create_movie
      set_rented_movies
      get ("#{user_rented_movies_movies_path}?api_key=#{@user.api_key}")
      expect(response).to have_http_status(200)
      expect(response.body).to eq(@user.rented.to_json)
    end
  end

  describe "POST /movies/:id/rent" do
    it "should rent a movie" do
      create_movie
      movie = Movie.first
      old_available_copies = movie.available_copies
      old_user_rented = @user.rented.count
      post ("#{rent_movie_path(movie)}?api_key=#{@user.api_key}")
      expect(response).to have_http_status(200)
      movie.reload
      expect(movie.available_copies).to eq(old_available_copies - 1)
      @user.reload
      expect(@user.rented.count).to eq(old_user_rented + 1)
      expect(JSON.parse(response.body)).to eq(JSON.parse(movie.to_json))
    end

    it "should fail when movie doesn't exist" do
      post ("#{rent_movie_path(-1)}?api_key=#{@user.api_key}")
      expect(response).to have_http_status(404)
      expect(response.body).to eq({ error: "The movie with ID -1 doesn't exist" }.to_json)
    end

    it "should fail when movie has no available copies" do
      create_movie(0)
      movie = Movie.first
      post ("#{rent_movie_path(movie)}?api_key=#{@user.api_key}")
      expect(response).to have_http_status(406)
      expect(response.body).to eq({ error: "#{movie.title} has no available copies for rent" }.to_json)
    end
  end

  describe "POST /movies/:id/return" do
    it "should return a movie" do
      create_movie
      set_rented_movies
      movie = Movie.first
      old_available_copies = movie.available_copies
      old_user_rentals = @user.rentals.where(status: :rented).count
      post ("#{return_movie_path(movie)}?api_key=#{@user.api_key}")
      expect(response).to have_http_status(200)
      movie.reload
      expect(movie.available_copies).to eq(old_available_copies + 1)
      @user.reload
      expect(@user.rentals.where(status: :rented).count).to eq(old_user_rentals - 1)
      expect(JSON.parse(response.body)).to eq(JSON.parse(movie.to_json))
    end

    it "should fail when movie doesn't exist" do
      post ("#{return_movie_path(-1)}?api_key=#{@user.api_key}")
      expect(response).to have_http_status(404)
      expect(response.body).to eq({ error: "The movie with ID -1 doesn't exist" }.to_json)
    end

    it "should fail when user has no rentals for movie" do
      create_movie
      movie = Movie.first
      post ("#{return_movie_path(movie)}?api_key=#{@user.api_key}")
      expect(response).to have_http_status(404)
      expect(response.body).to eq({ error: "You don't have any rentals pending for the movie #{movie.title}" }.to_json)
    end
  end

  def create_movie(available_copies=2)
    Movie.create! title: 'Indiana Jones And The Last Crusade', available_copies: available_copies, genre: 'Adventure', rating: 9.5
    Movie.create! title: 'Ace Ventura', available_copies: available_copies, genre: 'Comedy', rating: 9.5
    Movie.create! title: 'Riders Of The Lost Ark', available_copies: available_copies, genre: 'Adventure', rating: 9.0
    Movie.create! title: 'Ace Ventura 2', available_copies: available_copies, genre: 'Comedy', rating: 9.0
  end

  def set_rented_movies
    @user.rented << Movie.first
  end

  def set_favorites
    @user.favorites << Movie.second
  end

end
