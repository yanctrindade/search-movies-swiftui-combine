import SwiftUI
import WebKit

struct MovieDetailView: View {

    @StateObject private var viewModel: MovieDetailViewModel
    
    init(viewModel: MovieDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8.0) {
                AsyncImageView(url: viewModel.item.poster, cornerRadius: 10)
                Text(viewModel.item.title)
                    .foregroundColor(.white)
                    .font(.title3)
                if let plot = viewModel.item.plot {
                    Text(plot)
                        .foregroundColor(.white)
                        .font(.caption)
                }
                if let rating = viewModel.item.imdbRating {
                    Text("IMDb rating: \(rating)")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
            .onAppear(perform: {
                viewModel.fetchMovieDetails()
            })
            .padding()
            .ignoresSafeArea()
        }
        .background(Color.black)
        .navigationBarTitle("Details", displayMode: .inline)
    }

}
