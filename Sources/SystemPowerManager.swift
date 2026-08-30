import Foundation
import Combine
import SwiftUI
import AppKit
import UserNotifications

class SystemPowerManager: ObservableObject {
    static let shared = SystemPowerManager()
    
    @Published var isAwake: Bool = false
    private var timer: Timer?
    
    // Internal State
    private var userManuallyDisarmed = false
    private var armedByAutomation = false
    
    let monitoredApps = ["Terminal", "Xcode", "Cursor", "ChatGPT", "Claude", "Visual Studio Code", "Code", "Google Chrome", "Safari"]
    
    init() {
        checkStatus()
        startLoop()
    }
    
    private func startLoop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.routineCheck()
            self?.startLoop()
        }
    }
    
    func routineCheck() {
        let disarmOnLowBattery = UserDefaults.standard.object(forKey: "disarmOnLowBattery") as? Bool ?? true
        let lowBatteryLevel = UserDefaults.standard.object(forKey: "lowBatteryLevel") as? Double ?? 20.0
        let activateForApps = UserDefaults.standard.bool(forKey: "activateForApps")
        
        print("routineCheck running, activateForApps: \(activateForApps)")
        checkStatus()
        
        let battery = getBatteryPercentage() ?? 100.0
        let isCharging = isChargerConnected()
        
        // 1. Safety Check: Disarm if battery drops too low
        if disarmOnLowBattery && !isCharging && battery < lowBatteryLevel {
            if isAwake {
                print("Battery critically low. Forcing disarm.")
                setAwake(false, isManual: false)
            }
            return // Prevent automation from re-arming while battery is low
        }
        
        // 2. Automation Check: Trigger on monitored apps
        if activateForApps {
            let runningApps = NSWorkspace.shared.runningApplications.compactMap { $0.localizedName }
            let isMonitoredAppRunning = !Set(runningApps).isDisjoint(with: Set(monitoredApps))
            
            if isMonitoredAppRunning {
                // If it should be armed, is currently disarmed, and the user hasn't explicitly overridden it
                if !isAwake && !userManuallyDisarmed {
                    print("Monitored app opened. Auto-arming.")
                    armedByAutomation = true
                    setAwake(true, isManual: false)
                }
            } else {
                // If no monitored apps are running, reset the override state
                userManuallyDisarmed = false
                
                // If we automatically armed it earlier, disarm it now
                if isAwake && armedByAutomation {
                    print("Monitored app closed. Auto-disarming.")
                    armedByAutomation = false
                    setAwake(false, isManual: false)
                }
            }
        }
    }
    
    func setAwakeState(_ state: Bool) {
        let disarmOnLowBattery = UserDefaults.standard.object(forKey: "disarmOnLowBattery") as? Bool ?? true
        let lowBatteryLevel = UserDefaults.standard.object(forKey: "lowBatteryLevel") as? Double ?? 20.0
        
        let battery = getBatteryPercentage() ?? 100.0
        let isCharging = isChargerConnected()
        
        // Safety lock check: Refuse to arm if battery is too low
        if state && !isAwake && disarmOnLowBattery && !isCharging && battery < lowBatteryLevel {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Battery Too Low"
                alert.informativeText = "Cannot arm Owl because your battery is below the \(Int(lowBatteryLevel))% safety limit."
                alert.alertStyle = .warning
                alert.runModal()
            }
            return
        }
        
        setAwake(state, isManual: true)
    }
    
    func toggleAwake() {
        setAwakeState(!isAwake)
    }
    
    private func setAwake(_ state: Bool, isManual: Bool) {
        if isManual {
            if !state {
                // User explicitly turned it off. Record this so automation doesn't fight them.
                userManuallyDisarmed = true
                armedByAutomation = false
            } else {
                // User explicitly turned it on.
                userManuallyDisarmed = false
            }
        }
        
        shell("sudo -n pmset -a disablesleep \(state ? 1 : 0)")
        DispatchQueue.main.async {
            self.isAwake = state
        }
        
        if isManual {
            sendNotification(for: state)
        }
    }
    
    private func sendNotification(for state: Bool) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Owl"
                content.body = state ? "Armed (Mac will stay awake)" : "Disarmed (Mac can sleep)"
                content.sound = .default
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                center.add(request)
            }
        }
    }
    
    func checkStatus() {
        let output = shell("pmset -g | grep SleepDisabled")
        DispatchQueue.main.async {
            self.isAwake = output.contains("1")
        }
    }
    
    func restoreStateOnExit() {
        if isAwake {
            shell("sudo -n pmset -a disablesleep 0")
        }
    }
    
    private func getBatteryPercentage() -> Double? {
        let output = shell("pmset -g batt")
        do {
            let regex = try NSRegularExpression(pattern: "(\\d+)%")
            let nsString = output as NSString
            let results = regex.matches(in: output, range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                let percentStr = nsString.substring(with: match.range(at: 1))
                return Double(percentStr)
            }
        } catch { }
        return nil
    }
    
    private func isChargerConnected() -> Bool {
        let output = shell("pmset -g batt")
        return output.contains("AC Power")
    }
    
    @discardableResult
    private func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output
            }
        } catch { }
        return ""
    }
}
