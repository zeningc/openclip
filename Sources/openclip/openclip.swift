import SwiftUI

@main
struct openclip: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("openclip", systemImage: "clipboard") {
            MenuBarMenuView()
                .environmentObject(appDelegate.container.store)
                .environmentObject(appDelegate.container.picker)
                .environmentObject(appDelegate.container.preferences)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appDelegate.container.store)
                .environmentObject(appDelegate.container.preferences)
        }
    }
}
