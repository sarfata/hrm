import Carbon.HIToolbox

enum KeyCodeLabel {
    /// Returns a human-readable label for a given keycode.
    /// Uses the current keyboard layout to translate keycodes to characters.
    static func label(for keyCode: UInt16) -> String {
        guard let inputSource = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
              let layoutDataRef = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData)
        else {
            return String(format: "0x%02X", keyCode)
        }

        let layoutData = unsafeBitCast(layoutDataRef, to: CFData.self)
        let keyboardLayout = unsafeBitCast(CFDataGetBytePtr(layoutData), to: UnsafePointer<UCKeyboardLayout>.self)

        var deadKeyState: UInt32 = 0
        var length = 0
        var chars = [UniChar](repeating: 0, count: 4)

        let status = UCKeyTranslate(
            keyboardLayout,
            keyCode,
            UInt16(kUCKeyActionDisplay),
            0,
            UInt32(LMGetKbdType()),
            UInt32(kUCKeyTranslateNoDeadKeysBit),
            &deadKeyState,
            4,
            &length,
            &chars
        )

        if status == noErr, length > 0 {
            return String(utf16CodeUnits: chars, count: length).uppercased()
        }

        return String(format: "0x%02X", keyCode)
    }
}
