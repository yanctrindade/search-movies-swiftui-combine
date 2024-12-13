import Combine
import Foundation

class MovieFeedViewModel: ObservableObject {
    
    enum State: Equatable {
        case initial
        case fetched
        case error(_ message: String)
        case noResults
        case loading
    }
    
    enum Action {
        case fetchMovies(text: String)
    }
    
    @Published var state: State = .initial
    @Published var items: Array<Movie>
    @Published var searchText = ""
    @Published var favorites: [Movie] = []
    
    private let favoritesKey = "favoriteMovies"
    
    private let networkClient: NetworkClient
    private var cancellables = Set<AnyCancellable>()
    
    init(items: Array<Movie> = [], networkClient: NetworkClient = NetworkClientImp()) {
        self.items = items
        self.networkClient = networkClient
        setupBindings()
        loadFavorites()
    }
    
    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.performSearch(with: text)
            }
            .store(in: &cancellables)
    }
    
    func send(action: Action) {
        switch action {
        case let .fetchMovies(text):
            performSearch(with: text)
        }
    }
    
    private func performSearch(with searchTerm: String) {
        if searchTerm.isEmpty {
            state = .initial
            items.removeAll()
            return
        }
        
        state = .loading
        
        networkClient.searchMovies(with: searchTerm)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.state = .loading
                    }
                })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.state = .error("Failed to fetch movies: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                if response.search.isEmpty {
                    self.state = .noResults
                } else {
                    self.state = .fetched
                    self.items = response.search
                }
            })
            .store(in: &cancellables)
    }
}

extension MovieFeedViewModel {

    func saveFavorites() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    func loadFavorites() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? decoder.decode([Movie].self, from: data) {
            favorites = decoded
        }
    }

    func toggleFavorite(for movie: Movie) {
        if favorites.contains(where: { $0.imdbID == movie.imdbID }) {
            favorites.removeAll { $0.imdbID == movie.imdbID }
        } else {
            favorites.append(movie)
        }
        saveFavorites()
    }

    func isFavorite(_ movie: Movie) -> Bool {
        favorites.contains(where: { $0.imdbID == movie.imdbID })
    }
}
