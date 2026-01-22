require "json"
require "net/http"

class OmdbController < ApplicationController
  def search
    query = params[:query].to_s.strip
    return render json: [] if query.blank?

    data = omdb_request(s: query)
    results = Array(data["Search"]).map do |item|
      {
        title: item["Title"],
        year: item["Year"],
        imdb_id: item["imdbID"],
        poster_url: item["Poster"] == "N/A" ? nil : item["Poster"]
      }
    end

    render json: results
  end

  def details
    imdb_id = params[:imdb_id].to_s.strip
    return render json: {}, status: :bad_request if imdb_id.blank?

    data = omdb_request(i: imdb_id, plot: "full")
    return render json: {}, status: :not_found unless data["Response"] == "True"

    render json: {
      title: data["Title"],
      overview: data["Plot"] == "N/A" ? nil : data["Plot"],
      poster_url: data["Poster"] == "N/A" ? nil : data["Poster"],
      rating: data["imdbRating"] == "N/A" ? nil : data["imdbRating"].to_f
    }
  end

  private

  def omdb_request(params)
    api_key = ENV["OMDB_API_KEY"].to_s
    return {} if api_key.empty?

    uri = URI("https://www.omdbapi.com/")
    uri.query = params.merge(apikey: api_key).to_query
    response = Net::HTTP.get_response(uri)
    return {} unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.warn("OMDb error: #{e.message}")
    {}
  end
end
