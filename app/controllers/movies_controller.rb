class MoviesController < ApplicationController
  before_action :authenticate
  before_action :get_user, except: [:index]
  before_action :get_movie, only: [:rent, :return]

  def index
    @movies = Movie.all
    render json: @movies
  end

  def recommendations
    @recommendations = RecommendationEngine.new(@user.favorites, @user.rented).recommendations
    render json: @recommendations
  end

  def user_rented_movies
    @rented = @user.rented
    render json: @rented
  end

  def rent
    return render json: { error: "The movie with ID #{params[:id]} doesn't exist" }, status: :not_found if !@movie.present?
    return render json: { error: "#{@movie.title} has no available copies for rent" }, status: :not_acceptable if @movie.available_copies <= 0
    @movie.available_copies -= 1
    @movie.save
    @user.rented << @movie
    render json: @movie
  end

  def return
    return render json: { error: "The movie with ID #{params[:id]} doesn't exist" }, status: :not_found if !@movie.present?
    rentals = @user.rentals.where(movie: @movie, status: :rented)
    return render json: { error: "You don't have any rentals pending for the movie #{@movie.title}" }, status: :not_found if !rentals.present?
    quantity = rentals.size
    rentals.update_all status: :delivered
    @movie.available_copies += quantity
    @movie.save
    render json: @movie
  end

  private

    def authenticate
      auth = false

      error = 'Invalid API Key'

      if params[:api_key].present?
        auth = User.find_by(api_key: params[:api_key]).present?
      else
        error = 'API Key is missing. Please include api_key parameter on request'
      end
      render json: { error: error }, status: :unauthorized if !auth
    end

    def get_user
      @user = User.find_by(api_key: params[:api_key])
    end

    def get_movie
      @movie = Movie.find(params[:id]) rescue nil
    end
end