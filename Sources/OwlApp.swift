import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillTerminate(_ notification: Notification) {
        SystemPowerManager.shared.restoreStateOnExit()
    }
}

@main
struct OwlApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var powerManager = SystemPowerManager.shared
    
    var body: some Scene {
        MenuBarExtra("Owl", systemImage: powerManager.isAwake ? "lightbulb.fill" : "lightbulb") {
            Button(powerManager.isAwake ? "Disarm (Allow Sleep)" : "Arm (Keep Awake)") {
                powerManager.toggleAwake()
            }
            
            Divider()
            
            SettingsLink {
                Text("Settings...")
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        
        Settings {
            SettingsView()
                .preferredColorScheme(.dark)
                .tint(.blue)
        }
    }
}
