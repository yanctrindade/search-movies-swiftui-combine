import SwiftUI

@main
struct flicker_testApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MovieFeedView()
            }
        }
    }
}
