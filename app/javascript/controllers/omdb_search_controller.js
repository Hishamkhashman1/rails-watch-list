import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "results", "selected", "movieId", "title", "overview", "posterUrl", "rating"]
  static values = { searchUrl: String, detailsUrl: String }

  connect() {
    this.debouncedSearch = this.debounce(this.search.bind(this), 300)
  }

  queueSearch() {
    this.debouncedSearch()
  }

  async search() {
    const query = this.queryTarget.value.trim()

    if (query.length < 2) {
      this.clearResults()
      return
    }

    try {
      const response = await fetch(`${this.searchUrlValue}?query=${encodeURIComponent(query)}`)
      const results = await response.json()
      this.renderResults(results)
    } catch (error) {
      this.renderMessage("Search unavailable right now.")
    }
  }

  renderResults(results) {
    this.resultsTarget.innerHTML = ""

    if (!results.length) {
      this.renderMessage("No matches found.")
      return
    }

    results.forEach((item) => {
      const button = document.createElement("button")
      button.type = "button"
      button.className = "omdb-result"
      button.textContent = `${item.title}${item.year ? ` (${item.year})` : ""}`
      button.dataset.imdbId = item.imdb_id
      button.addEventListener("click", () => this.selectResult(item.imdb_id))
      this.resultsTarget.appendChild(button)
    })
  }

  async selectResult(imdbId) {
    try {
      const response = await fetch(`${this.detailsUrlValue}?imdb_id=${encodeURIComponent(imdbId)}`)
      const data = await response.json()
      if (!data.title) {
        this.renderMessage("Could not load details.")
        return
      }

      this.titleTarget.value = data.title
      this.overviewTarget.value = data.overview || ""
      this.posterUrlTarget.value = data.poster_url || ""
      this.ratingTarget.value = data.rating || ""
      this.movieIdTarget.value = ""

      this.selectedTarget.textContent = `Selected: ${data.title}`
      this.clearResults()
    } catch (error) {
      this.renderMessage("Could not load details.")
    }
  }

  renderMessage(message) {
    this.resultsTarget.innerHTML = ""
    const notice = document.createElement("div")
    notice.className = "omdb-message"
    notice.textContent = message
    this.resultsTarget.appendChild(notice)
  }

  clearResults() {
    this.resultsTarget.innerHTML = ""
  }

  debounce(fn, delay) {
    let timeout
    return (...args) => {
      clearTimeout(timeout)
      timeout = setTimeout(() => fn(...args), delay)
    }
  }
}
