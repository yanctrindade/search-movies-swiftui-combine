import SwiftUI
import Combine

struct MovieFeedView: View {
    
    @StateObject private var viewModel = MovieFeedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                searchBar
                    .padding(.top, 64)
                switch viewModel.state {
                case .initial:
                    showMessage("Find Movies using OMDb API\ntyping on search bar !")
                case .fetched:
                    movieList
                case .error:
                    showMessage("Ooops! Something goes wrong, try again!")
                case .loading:
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(3)
                    Spacer()
                case .noResults:
                    showMessage("No results found for: \(viewModel.searchText)")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.black)
            .ignoresSafeArea()
        }
    }
    
    var searchBar: some View {
        TextField("Search", text: $viewModel.searchText)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .accessibility(label: Text("SearchBar"))
            .accessibility(hint: Text("Input words to find pictures using flicker API"))
    }
    
    var movieList: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.items, id: \.self) { item in
                    ListItemView(viewModel: viewModel, item: item)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func showMessage(_ text: String) -> some View {
        Group {
            Spacer()
            Text(text)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.headline)
            Spacer()
        }
    }
}

struct ListItemView: View {
    @ObservedObject var viewModel: MovieFeedViewModel
    var item: Movie
    
    var body: some View {
        NavigationLink(destination: MovieDetailView(viewModel: .init(item: item))) {
            HStack() {
                poster
                movieInfo
                Spacer()
                favoriteButton
            }
        }
    }
    
    var poster: some View {
        AsyncImageView(url: item.poster)
            .frame(maxHeight: 200)
            .aspectRatio(contentMode: .fit)
            .cornerRadius(10)
            .accessibility(label: Text(item.title))
            .accessibility(hint: Text("Double-tap to view a larger version"))
    }
    
    var movieInfo: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .multilineTextAlignment(.leading)
                .fontWeight(.medium)
            Text("Year of release: \(item.year)")
                .fontWeight(.light)
        }
        .foregroundStyle(.white)
    }
    
    var favoriteButton: some View {
        Button(action: {
            viewModel.toggleFavorite(for: item)
        }) {
            Image(systemName: viewModel.isFavorite(item) ? "heart.fill" : "heart")
                .foregroundStyle(viewModel.isFavorite(item) ? .red : .gray)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MovieFeedView()
}

