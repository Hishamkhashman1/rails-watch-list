require "json"
require "net/http"
require "uri"

Bookmark.destroy_all
List.destroy_all
Movie.destroy_all

def fetch_omdb_data(title, api_key)
  return {} if api_key.nil? || api_key.strip.empty?

  uri = URI("https://www.omdbapi.com/?t=#{URI.encode_www_form_component(title)}&apikey=#{api_key}")
  response = Net::HTTP.get_response(uri)
  return {} unless response.is_a?(Net::HTTPSuccess)

  data = JSON.parse(response.body)
  return {} unless data["Response"] == "True"

  {
    overview: data["Plot"].to_s == "N/A" ? nil : data["Plot"],
    poster_url: data["Poster"].to_s == "N/A" ? nil : data["Poster"],
    rating: data["imdbRating"].to_s == "N/A" ? nil : data["imdbRating"].to_f
  }
rescue StandardError => e
  warn "OMDb fetch failed for #{title}: #{e.message}"
  {}
end

catalog = [
  {
    title: "Dune",
    overview: "A gifted heir must travel to the most dangerous planet in the universe to save his family and people.",
    poster_url: "https://picsum.photos/seed/dune/600/900",
    rating: 8.1
  },
  {
    title: "Blade Runner 2049",
    overview: "A new blade runner unearths a long-buried secret that could plunge society into chaos.",
    poster_url: "https://picsum.photos/seed/blade-runner-2049/600/900",
    rating: 8.0
  },
  {
    title: "Interstellar",
    overview: "Explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
    poster_url: "https://picsum.photos/seed/interstellar/600/900",
    rating: 8.6
  },
  {
    title: "The Matrix",
    overview: "A hacker learns the world is a simulation and joins a rebellion to free humanity.",
    poster_url: "https://picsum.photos/seed/the-matrix/600/900",
    rating: 8.7
  },
  {
    title: "Rick and Morty",
    overview: "A cynical scientist drags his grandson on chaotic, interdimensional adventures.",
    poster_url: "https://picsum.photos/seed/rick-and-morty/600/900",
    rating: 9.1
  },
  {
    title: "The Expanse",
    overview: "A detective and a rogue crew uncover a conspiracy that threatens the solar system.",
    poster_url: "https://picsum.photos/seed/the-expanse/600/900",
    rating: 8.5
  },
  {
    title: "Stranger Things",
    overview: "Kids in a small town confront a terrifying mystery tied to a secret lab and the Upside Down.",
    poster_url: "https://picsum.photos/seed/stranger-things/600/900",
    rating: 8.7
  },
  {
    title: "Andor",
    overview: "A thief becomes a rebel spy in the early days of the uprising.",
    poster_url: "https://picsum.photos/seed/andor/600/900",
    rating: 8.4
  },
  {
    title: "Cowboy Bebop",
    overview: "A bounty hunter crew drifts through space taking odd jobs and facing old ghosts.",
    poster_url: "https://picsum.photos/seed/cowboy-bebop/600/900",
    rating: 8.9
  },
  {
    title: "Akira",
    overview: "In Neo-Tokyo, a biker gang member's powers spiral out of control.",
    poster_url: "https://picsum.photos/seed/akira/600/900",
    rating: 8.0
  },
  {
    title: "Ghost in the Shell",
    overview: "A cyborg officer hunts a mysterious hacker in a hyper-connected future.",
    poster_url: "https://picsum.photos/seed/ghost-in-the-shell/600/900",
    rating: 8.0
  },
  {
    title: "Attack on Titan",
    overview: "Humanity fights for survival against terrifying giants.",
    poster_url: "https://picsum.photos/seed/attack-on-titan/600/900",
    rating: 9.0
  }
]

omdb_key = ENV["OMDB_API_KEY"]
movies = catalog.map do |entry|
  omdb_data = fetch_omdb_data(entry[:title], omdb_key)
  entry.merge(omdb_data.compact)
end

movies.each { |attributes| Movie.create!(attributes) }

movies_list = List.create!(name: "Movies")
series_list = List.create!(name: "Series")
anime_list = List.create!(name: "Anime")

Bookmark.create!(
  list: movies_list,
  movie: Movie.find_by!(title: "Dune"),
  comment: "Epic desert saga."
)
Bookmark.create!(
  list: movies_list,
  movie: Movie.find_by!(title: "Blade Runner 2049"),
  comment: "Moody neon noir."
)
Bookmark.create!(
  list: movies_list,
  movie: Movie.find_by!(title: "Interstellar"),
  comment: "Mind-bending odyssey."
)
Bookmark.create!(
  list: movies_list,
  movie: Movie.find_by!(title: "The Matrix"),
  comment: "Classic cyberpunk."
)

Bookmark.create!(
  list: series_list,
  movie: Movie.find_by!(title: "Rick and Morty"),
  comment: "Chaotic genius."
)
Bookmark.create!(
  list: series_list,
  movie: Movie.find_by!(title: "The Expanse"),
  comment: "Smart space opera."
)
Bookmark.create!(
  list: series_list,
  movie: Movie.find_by!(title: "Stranger Things"),
  comment: "Spooky synth vibes."
)
Bookmark.create!(
  list: series_list,
  movie: Movie.find_by!(title: "Andor"),
  comment: "Gritty rebellion."
)

Bookmark.create!(
  list: anime_list,
  movie: Movie.find_by!(title: "Cowboy Bebop"),
  comment: "Space jazz classics."
)
Bookmark.create!(
  list: anime_list,
  movie: Movie.find_by!(title: "Akira"),
  comment: "Iconic cyber anime."
)
Bookmark.create!(
  list: anime_list,
  movie: Movie.find_by!(title: "Ghost in the Shell"),
  comment: "Philosophical thriller."
)
Bookmark.create!(
  list: anime_list,
  movie: Movie.find_by!(title: "Attack on Titan"),
  comment: "Intense survival drama."
)
