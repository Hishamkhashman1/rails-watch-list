class BookmarksController < ApplicationController
  before_action :set_list, only: %i[new create]

  def new
    @bookmark = Bookmark.new
  end

  def create
    @bookmark = Bookmark.new(bookmark_params.except(:movie_title, :movie_overview, :movie_poster_url, :movie_rating))
    @bookmark.list = @list

    if @bookmark.movie_id.blank?
      movie = find_or_create_movie_from_params
      @bookmark.movie = movie if movie
    end

    if @bookmark.save
      redirect_to @list
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    bookmark = Bookmark.find(params[:id])
    list = bookmark.list
    bookmark.destroy
    redirect_to list
  end

  private

  def set_list
    @list = List.find(params[:list_id])
  end

  def bookmark_params
    params.require(:bookmark).permit(:comment, :movie_id, :movie_title, :movie_overview, :movie_poster_url, :movie_rating)
  end

  def find_or_create_movie_from_params
    title = bookmark_params[:movie_title].to_s.strip
    return if title.blank?

    movie = Movie.find_or_initialize_by(title: title)
    return movie if movie.persisted?

    overview = bookmark_params[:movie_overview].to_s.strip
    rating = bookmark_params[:movie_rating].presence&.to_f
    poster_url = bookmark_params[:movie_poster_url].to_s.strip

    movie.overview = overview.presence || "No overview yet."
    movie.rating = rating if rating
    movie.poster_url = poster_url if poster_url.present?

    movie.save ? movie : nil
  end
end
