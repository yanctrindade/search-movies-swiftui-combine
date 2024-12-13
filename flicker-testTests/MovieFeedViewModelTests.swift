import XCTest
@testable import flicker_test

class MovieFeedViewModelTests: XCTestCase {
    
    var viewModel: MovieFeedViewModel!
    var mockNetworkClient: MockNetworkClient!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        viewModel = MovieFeedViewModel(networkClient: mockNetworkClient)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkClient = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.state, .initial)
        XCTAssertTrue(viewModel.items.isEmpty)
        XCTAssertEqual(viewModel.searchText, "")
    }
    
    func testFetchMovies() throws {
        viewModel.searchText = "cars"
        viewModel.send(action: .fetchMovies(text: viewModel.searchText))
        XCTAssertEqual(viewModel.state, .loading)
        XCTAssertEqual(viewModel.items.count, 0)
    }
    
    func testFetchMoviesWithEmptyString() throws {
        viewModel.searchText = ""
        viewModel.send(action: .fetchMovies(text: viewModel.searchText))
        XCTAssertEqual(viewModel.state, .initial)
        XCTAssertEqual(viewModel.items.count, 0)
    }

}
