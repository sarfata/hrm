import Combine
import Foundation

@MainActor
final class KeyboardMonitor: ObservableObject {
    @Published private(set) var discoveredKeyboards: [KeyboardDevice] = []
    private var seenTypes: Set<Int> = []

    // The CGEvent keyboardEventKeyboardType field identifies the keyboard
    // *layout type* (ANSI, ISO, JIS), not the physical device. Map known
    // values to human-readable names.
    private static let knownLayoutNames: [Int: String] = [
        40: "ANSI (US/International)",
        41: "ISO (European)",
        42: "JIS (Japanese)",
    ]

    nonisolated func recordKeyboardType(_ type: Int) {
        Task { @MainActor in
            guard !seenTypes.contains(type) else { return }
            seenTypes.insert(type)
            let name = Self.knownLayoutNames[type] ?? "Layout \(type)"
            discoveredKeyboards.append(KeyboardDevice(keyboardType: type, name: name))
        }
    }
}
