import SwiftUI

@main
struct ReadyByEightApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .preferredColorScheme(.dark)
        }
    }
}
