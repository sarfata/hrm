import Carbon.HIToolbox
import CoreGraphics

enum KeyCodeLabel {
    /// Returns a human-readable label for a given keycode.
    /// Uses the current keyboard layout to translate keycodes to characters.
    static func label(for keyCode: UInt16) -> String {
        if let special = specialKeyLabels[keyCode] {
            return special
        }

        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
            return String(format: "0x%02X", keyCode)
        }

        var length = 0
        var chars = [UniChar](repeating: 0, count: 4)
        event.keyboardGetUnicodeString(maxStringLength: 4, actualStringLength: &length, unicodeString: &chars)

        if length > 0 {
            return String(utf16CodeUnits: chars, count: length).uppercased()
        }

        return String(format: "0x%02X", keyCode)
    }

    private static let specialKeyLabels: [UInt16: String] = [
        UInt16(kVK_ANSI_Semicolon): ";",
        UInt16(kVK_ANSI_Quote): "'",
        UInt16(kVK_ANSI_Comma): ",",
        UInt16(kVK_ANSI_Period): ".",
        UInt16(kVK_ANSI_Slash): "/",
        UInt16(kVK_ANSI_Backslash): "\\",
        UInt16(kVK_ANSI_LeftBracket): "[",
        UInt16(kVK_ANSI_RightBracket): "]",
        UInt16(kVK_ANSI_Minus): "-",
        UInt16(kVK_ANSI_Equal): "=",
        UInt16(kVK_ANSI_Grave): "`",
        UInt16(kVK_Space): "Space",
        UInt16(kVK_Tab): "Tab",
        UInt16(kVK_Return): "Return",
        UInt16(kVK_Escape): "Esc",
    ]
}
