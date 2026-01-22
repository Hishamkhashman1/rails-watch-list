class Bookmark < ApplicationRecord
  belongs_to :movie
  belongs_to :list

  attr_accessor :movie_title, :movie_overview, :movie_poster_url, :movie_rating

  validates :comment, presence: true, length: { minimum: 6 }
  validates :movie_id, uniqueness: { scope: :list_id }
end
