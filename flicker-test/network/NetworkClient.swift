import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case noData
    case missingApiKey
    case httpError(_ statusCode: Int)
    case requestError(_ error: Error)
    case invalidResponse
}

protocol NetworkClient {
    func searchMovies(with search: String) -> AnyPublisher<SearchMovieResponse, NetworkError>
    func searchMovieBy(id: String) -> AnyPublisher<Movie, NetworkError>
}

class NetworkClientImp: NetworkClient {
    
    private let baseURL = "http://www.omdbapi.com/"
    private let session = URLSession(configuration: .default)

    private func performRequest<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]) -> AnyPublisher<T, NetworkError> {
        guard var components = URLComponents(string: baseURL) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        guard let apiKey = ProcessInfo.processInfo.environment["OMDB_API_KEY"] else {
            return Fail(error: NetworkError.missingApiKey).eraseToAnyPublisher()
        }

        components.queryItems = queryItems + [URLQueryItem(name: "apikey", value: apiKey)]

        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)

        return session.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    if let httpResponse = result.response as? HTTPURLResponse {
                        throw NetworkError.httpError(httpResponse.statusCode)
                    } else {
                        throw NetworkError.invalidResponse
                    }
                }
                
                if let str = String(data: result.data, encoding: .utf8) {
                    print("Successfully decoded response:\n")
                    print(str)
                }

                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let decodingError = error as? DecodingError {
                    return NetworkError.requestError(decodingError)
                } else {
                    return NetworkError.requestError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    func searchMovies(with search: String) -> AnyPublisher<SearchMovieResponse, NetworkError> {
        return performRequest(
            endpoint: "search",
            queryItems: [
                URLQueryItem(name: "type", value: "movie"),
                URLQueryItem(name: "s", value: search)
            ]
        )
    }
    
    func searchMovieBy(id: String) -> AnyPublisher<Movie, NetworkError> {
        return performRequest(
            endpoint: "movie",
            queryItems: [
                URLQueryItem(name: "type", value: "movie"),
                URLQueryItem(name: "i", value: id)
            ]
        )
    }
}


