import SwiftUI

struct KeyBindingDetailView: View {
    @Binding var binding: KeyBinding
    let config: Configuration
    var onChanged: () -> Void
    var onCaptureKey: (@escaping (UInt16) -> Void) -> Void = { _ in }
    var onCancelCapture: () -> Void = {}
    var allBindings: [KeyBinding] = []

    @State private var isListening = false
    @State private var duplicateWarning: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.backward.circle.fill")
                        .font(.system(size: 24))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.primary, .quaternary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)

                Text("Key: \(binding.label)")
                    .font(.headline)

                Spacer()

                Toggle(binding.enabled ? "Enabled" : "Disabled", isOn: $binding.enabled)
                    .toggleStyle(.switch)
                    .fixedSize()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            Form {
            Section("Key Binding") {
                HStack {
                    Text("Key")
                    Spacer()
                    if isListening {
                        Text("Press a key…")
                            .foregroundStyle(.orange)
                            .font(.body.weight(.medium))
                        Button("Cancel") {
                            stopListening()
                        }
                        .controlSize(.small)
                    } else {
                        Text(binding.label)
                            .foregroundStyle(.secondary)
                        Button("Reassign") {
                            startListening()
                        }
                        .controlSize(.small)
                    }
                }

                if let warning = duplicateWarning {
                    Text(warning)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Picker("Modifier", selection: $binding.modifier) {
                    Text("None").tag(Modifier?.none)
                    ForEach(Modifier.allCases) { mod in
                        Text(mod.symbol + " " + mod.displayName).tag(Modifier?.some(mod))
                    }
                }

                Text("Position: \(binding.position.displayName)")
                    .foregroundStyle(.secondary)
            }

            Section("Bilateral Filtering") {
                overrideToggle(
                    label: "Bilateral Filtering",
                    value: $binding.bilateralFiltering,
                    globalDefault: config.bilateralFiltering
                )
            }

            Section("Timing Overrides") {
                overrideIntField(
                    label: "Quick Tap Term",
                    value: $binding.quickTapTermMs,
                    globalDefault: config.quickTapTermMs
                )

                overrideIntField(
                    label: "Require Prior Idle",
                    value: $binding.requirePriorIdleMs,
                    globalDefault: config.requirePriorIdleMs
                )
            }
        }
        .formStyle(.grouped)
        .fixedSize(horizontal: false, vertical: true)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: binding) { onChanged() }
        .onDisappear { stopListening() }
    }

    // MARK: - Key Listening

    private func startListening() {
        duplicateWarning = nil
        isListening = true
        onCaptureKey { keyCode in
            handleCapturedKey(keyCode)
        }
    }

    private func stopListening() {
        if isListening {
            isListening = false
            onCancelCapture()
        }
    }

    private func handleCapturedKey(_ keyCode: UInt16) {
        defer { isListening = false }

        if keyCode == 0x35 { // kVK_Escape
            return
        }

        if let existing = allBindings.first(where: { $0.position != binding.position && $0.keyCode == keyCode }) {
            duplicateWarning = "\"\(existing.label)\" is already assigned to another position."
            return
        }

        binding.keyCode = keyCode
        binding.label = KeyCodeLabel.label(for: keyCode)
        duplicateWarning = nil
    }

    // MARK: - Override Helpers

    private func overrideToggle(label: String, value: Binding<Bool?>, globalDefault: Bool) -> some View {
        HStack {
            Text(label)
            Spacer()
            Picker("", selection: value) {
                Text("Global (\(globalDefault ? "On" : "Off"))").tag(Bool?.none)
                Text("On").tag(Bool?.some(true))
                Text("Off").tag(Bool?.some(false))
            }
            .pickerStyle(.menu)
            .frame(width: 160)
        }
    }

    private func overrideIntField(label: String, value: Binding<Int?>, globalDefault: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let val = value.wrappedValue {
                Stepper(value: Binding(
                    get: { val },
                    set: { value.wrappedValue = $0 }
                ), in: 0...999, step: 10) {
                    HStack {
                        Text(label)
                        Spacer()
                        TextField("ms", value: Binding(
                            get: { val },
                            set: { value.wrappedValue = $0 }
                        ), format: .number)
                        .frame(width: 50)
                        .multilineTextAlignment(.trailing)
                        Text("ms")
                            .foregroundStyle(.secondary)
                    }
                }
                Button("Reset to Global") { value.wrappedValue = nil }
                    .font(.caption)
            } else {
                HStack {
                    Text(label)
                    Spacer()
                    Text("\(globalDefault)ms (global)")
                        .foregroundStyle(.secondary)
                    Button("Override") { value.wrappedValue = globalDefault }
                        .font(.caption)
                }
            }
        }
    }
}
