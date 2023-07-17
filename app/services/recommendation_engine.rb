class RecommendationEngine
  def initialize(favorite_movies, rented)
    @favorite_movies = favorite_movies
    @rented = rented
  end

  def recommendations
    favorite_rec = get_recommendations(@favorite_movies)
    rented_rec = get_recommendations(@rented)
    return { based_on_favorites: favorite_rec, based_on_reted: rented_rec }
  end

  private

    def get_recommendations(movies)
      genres = movies.pluck(:genre)
      common_genres = genres.group_by{ |e| e }.sort_by{ |k, v| -v.length }.map(&:first).take(3)
      return Movie.where(genre: common_genres, available_copies: 1...Float::INFINITY).order(rating: :desc).limit(10)
    end
end