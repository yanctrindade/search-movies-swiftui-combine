import SwiftUI
import Combine

class MovieDetailViewModel: ObservableObject {
    @Published var item: Movie
    let networkClient: NetworkClient
    private var cancellables = Set<AnyCancellable>()
    
    init(item: Movie, networkClient: NetworkClient = NetworkClientImp()) {
        self.item = item
        self.networkClient = networkClient
    }
    
    func fetchMovieDetails() {
        networkClient.searchMovieBy(id: item.imdbID)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { _ in
                // TODO: Add loading state if needed
            }, receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.handleError(error)
                }
            })
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                self?.updateItem(with: response)
            })
            .store(in: &cancellables)
    }
    
    private func updateItem(with newItem: Movie) {
        withAnimation {
            item = newItem
        }
    }
    
    private func handleError(_ error: NetworkError) {
        debugPrint("Failed to fetch movie details: \(error.localizedDescription)")
    }
}
