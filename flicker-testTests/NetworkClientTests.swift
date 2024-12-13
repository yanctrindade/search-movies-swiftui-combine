import XCTest
import Combine
@testable import flicker_test

class MockNetworkClient: NetworkClient {
    func searchMovies(with search: String) -> AnyPublisher<SearchMovieResponse, NetworkError> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let response = try decoder.decode(SearchMovieResponse.self, from: expectedMovieListResponseData)
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.requestError(error))
                .eraseToAnyPublisher()
        }
    }
    
    func searchMovieBy(id: String) -> AnyPublisher<Movie, NetworkError> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let response = try decoder.decode(Movie.self, from: expectedMockDetailResponseData)
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.requestError(error))
                .eraseToAnyPublisher()
        }
    }
}

// Updated Test Case
final class NetworkClientTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    
    func searchMoviesMockTest() {
        let searchTerm = "cars"
        let expectation = self.expectation(description: "Mock data should be fetched successfully")
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let expectedResponse = try! jsonDecoder.decode(SearchMovieResponse.self, from: expectedMovieListResponseData)
        
        let networkClient = MockNetworkClient()
        
        networkClient.searchMovies(with: searchTerm)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Failed with error: \(error)")
                }
            }, receiveValue: { response in
                XCTAssertEqual(expectedResponse, response)
                XCTAssertEqual(response.search.count, 2)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
    }
}

public let expectedMovieListResponseData = """
{
    "Search": [
        {
            "Title": "Dude, Where's My Car?",
            "Year": "2000",
            "imdbID": "tt0242423",
            "Type": "movie",
            "Poster": "https://m.media-amazon.com/images/M/MV5BNmE3NmUxNjUtYzIzMS00MmEzLWJjNjUtNmQ5OTcxMDJkMGNiXkEyXkFqcGc@._V1_SX300.jpg"
        },
        {
            "Title": "Drive My Car",
            "Year": "2021",
            "imdbID": "tt14039582",
            "Type": "movie",
            "Poster": "https://m.media-amazon.com/images/M/MV5BOGE5ZWRhYjYtNzVkMS00ZGU3LTg2MTMtODYyMmJlMDMyZjU0XkEyXkFqcGc@._V1_SX300.jpg"
        }
    ],
    "totalResults": "951",
    "Response": "True"
}
""".data(using: .utf8)!
                                                    
public let expectedMockDetailResponseData = """
{
    "Title": "Pokémon: Detective Pikachu",
    "Year": "2019",
    "Rated": "PG",
    "Released": "10 May 2019",
    "Runtime": "104 min",
    "Genre": "Adventure, Comedy, Family",
    "Director": "Rob Letterman",
    "Writer": "Dan Hernandez, Benji Samit, Rob Letterman",
    "Actors": "Ryan Reynolds, Justice Smith, Kathryn Newton",
    "Plot": "In a world where people collect Pokémon to do battle, a boy comes across an intelligent talking Pikachu who seeks to be a detective.",
    "Language": "English, Japanese",
    "Country": "United States, Japan, United Kingdom, Canada",
    "Awards": "10 nominations",
    "Poster": "https://m.media-amazon.com/images/M/MV5BNDU4Mzc3NzE5NV5BMl5BanBnXkFtZTgwMzE1NzI1NzM@._V1_SX300.jpg",
    "Ratings": [
        {
            "Source": "Internet Movie Database",
            "Value": "6.5/10"
        },
        {
            "Source": "Rotten Tomatoes",
            "Value": "68%"
        },
        {
            "Source": "Metacritic",
            "Value": "53/100"
        }
    ],
    "Metascore": "53",
    "imdbRating": "6.5",
    "imdbVotes": "187,605",
    "imdbID": "tt5884052",
    "Type": "movie",
    "DVD": "N/A",
    "BoxOffice": "$144,174,568",
    "Production": "N/A",
    "Website": "N/A",
    "Response": "True"
}
""".data(using: .utf8)!
