class MoviesController < ApplicationController
  before_action :authenticate

  def index
    @movies = Movie.all
    render json: @movies
  end

  def recommendations
    favorite_movies = User.find(params[:user_id]).favorites
    @recommendations = RecommendationEngine.new(favorite_movies).recommendations
    render json: @recommendations
  end

  def user_rented_movies
    @rented = User.find(params[:user_id]).rented
    render json: @rented
  end

  def rent
    user = User.find(params[:user_id])
    movie = Movie.find(params[:id])
    movie.available_copies -= 1
    movie.save
    user.rented << movie
    render json: movie
  end

  def authenticate
    auth = false

    error = 'Invalid API Key'

    if params[:api_key].present?
      user = User.where(api_key: params[:api_key])
      auth = user.present?
    else
      error = 'API Key is missing. Please include api_key parameter on request'
    end
    render json: { error: error }, status: :unauthorized if !auth
  end
end