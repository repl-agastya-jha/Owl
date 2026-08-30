import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            AutomationSettingsView()
                .tabItem {
                    Label("Automation", systemImage: "bolt.fill")
                }
        }
        .frame(width: 420, height: 350)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("openAtLogin") private var openAtLogin = false
    @AppStorage("disarmOnLowBattery") private var disarmOnLowBattery = true
    @AppStorage("lowBatteryLevel") private var lowBatteryLevel = 20.0
    
    @ObservedObject private var powerManager = SystemPowerManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Manual Control")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Toggle("Keep Mac Awake", isOn: Binding(
                    get: { powerManager.isAwake },
                    set: { newValue in powerManager.setAwakeState(newValue) }
                ))
                .toggleStyle(.switch)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Behavior")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Toggle("Open at login", isOn: $openAtLogin)
                    .toggleStyle(.switch)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Safety")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Toggle("Disarm on low battery", isOn: $disarmOnLowBattery)
                    .toggleStyle(.switch)
                
                HStack {
                    Text("Low battery level:")
                    Slider(value: $lowBatteryLevel, in: 5...50, step: 5)
                        .frame(width: 150)
                    Text("\(Int(lowBatteryLevel))%")
                        .frame(width: 40, alignment: .leading)
                }
                .disabled(!disarmOnLowBattery)
                .opacity(disarmOnLowBattery ? 1.0 : 0.5)
            }
            
            Spacer()
        }
        .padding(24)
    }
}

struct AutomationSettingsView: View {
    @AppStorage("activateForApps") private var activateForApps = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Automation")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Toggle("Activate for selected apps", isOn: $activateForApps)
                    .toggleStyle(.switch)
                
                if activateForApps {
                    Text("Terminal, Xcode, VSCode, and Cursor are currently monitored.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(24)
    }
}
