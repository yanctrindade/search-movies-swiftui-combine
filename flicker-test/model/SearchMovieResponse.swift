import Foundation

struct SearchMovieResponse: Codable, Equatable {
    let search: [Movie]
    let totalResults: String
    let response: String

    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
}

struct Movie: Codable, Hashable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: URL
    
    // Detail properties
    let rated: String?
    let released: String?
    let runtime: String?
    let genre: String?
    let director: String?
    let writer: String?
    let actors: String?
    let plot: String?
    let language: String?
    let country: String?
    let awards: String?
    let ratings: [Rating]?
    let metascore: String?
    let imdbRating: String?
    let imdbVotes: String?
    let dvd: String?
    let boxOffice: String?
    let production: String?
    let website: String?
    let response: String?

    enum CodingKeys: String, CodingKey {
            case title = "Title"
            case year = "Year"
            case imdbID
            case type = "Type"
            case poster = "Poster"
            // Additional keys
            case rated = "Rated"
            case released = "Released"
            case runtime = "Runtime"
            case genre = "Genre"
            case director = "Director"
            case writer = "Writer"
            case actors = "Actors"
            case plot = "Plot"
            case language = "Language"
            case country = "Country"
            case awards = "Awards"
            case ratings = "Ratings"
            case metascore = "Metascore"
            case imdbRating
            case imdbVotes
            case dvd = "DVD"
            case boxOffice = "BoxOffice"
            case production = "Production"
            case website = "Website"
            case response = "Response"
        }
}

extension Movie {
    struct Rating: Codable, Hashable {
        let source: String
        let value: String

        enum CodingKeys: String, CodingKey {
            case source = "Source"
            case value = "Value"
        }
    }
}
