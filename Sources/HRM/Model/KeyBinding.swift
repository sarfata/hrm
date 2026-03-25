struct KeyBinding: Codable, Identifiable, Equatable {
    var id: String { position.rawValue }
    var keyCode: UInt16
    var label: String
    var modifier: Modifier?
    var enabled: Bool
    let position: KeyPosition

    // Per-key overrides (nil = use global defaults)
    var quickTapTermMs: Int?
    var requirePriorIdleMs: Int?
    var bilateralFiltering: Bool?
}
