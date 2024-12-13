import SwiftUI
import Combine
import UIKit

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var imageSize: CGSize = .zero
    private var cancellable: AnyCancellable?
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    deinit {
        cancellable?.cancel()
    }

    func load() {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.image = $0
                self?.imageSize = $0?.size ?? .zero
            }
    }
}

struct AsyncImageView: View {
    @StateObject private var loader: ImageLoader
    var cornerRadius: CGFloat

    init(url: URL, cornerRadius: CGFloat = 0) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        VStack {
            Group {
                if let image = loader.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(cornerRadius)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
        .onAppear(perform: loader.load)
    }
}
