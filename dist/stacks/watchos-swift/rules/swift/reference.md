# watchOS Swift Reference

> Detailed patterns and examples for watchOS development.

## SwiftUI View Pattern

```swift
struct MyView: View {
    @StateObject private var viewModel = MyViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Compact, glanceable content
            }
        }
        .navigationTitle("Title")
    }
}
```

## Complication Timeline Provider

```swift
struct MyProvider: TimelineProvider {
    func placeholder(in context: Context) -> MyEntry {
        MyEntry(date: .now, value: "---")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MyEntry) -> Void) {
        completion(MyEntry(date: .now, value: "42"))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MyEntry>) -> Void) {
        var entries: [MyEntry] = []
        let currentDate = Date()
        
        for offset in 0..<5 {
            let date = Calendar.current.date(byAdding: .minute, value: offset * 15, to: currentDate)!
            entries.append(MyEntry(date: date, value: "\(offset)"))
        }
        
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
```

## WatchConnectivity Setup

```swift
class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        // Handle activation
    }
    
    // Required on iOS only
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}
```

## Haptic Feedback

```swift
// Play haptic feedback
WKInterfaceDevice.current().play(.click)
WKInterfaceDevice.current().play(.success)
WKInterfaceDevice.current().play(.failure)
```

## Battery-Efficient Networking

```swift
// Use shorter timeouts
let config = URLSessionConfiguration.default
config.timeoutIntervalForRequest = 15
config.timeoutIntervalForResource = 60

// Batch requests when possible
// Avoid polling - use background refresh
```
