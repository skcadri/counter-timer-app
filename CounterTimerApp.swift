import SwiftUI
import AVFoundation

// MARK: - App Entry Point

@main
struct CounterTimerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 340, minHeight: 480)
        }
        .windowResizability(.contentSize)
    }
}

// MARK: - Content View

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            CounterView()
            Divider()
            TimerSectionView()
        }
        .padding()
    }
}

// MARK: - Counter

struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("Counter")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("\(count)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: count)

            HStack(spacing: 12) {
                Button { count -= 1 } label: {
                    Image(systemName: "minus")
                        .frame(width: 44, height: 32)
                }
                .keyboardShortcut("-", modifiers: [])

                Button { count = 0 } label: {
                    Text("Reset")
                        .frame(width: 54, height: 32)
                }

                Button { count += 1 } label: {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 32)
                }
                .keyboardShortcut("=", modifiers: [])
            }
            .controlSize(.large)
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Timer

struct TimerSectionView: View {
    @State private var totalSeconds = 300 // default 5 min
    @State private var remaining = 0
    @State private var running = false
    @State private var timer: Timer?
    @State private var finished = false
    @State private var editing = false
    @State private var draft = ""
    @FocusState private var fieldFocused: Bool

    private let presets = [5, 10, 15, 25, 30, 60]

    private var displaySeconds: Int {
        running || finished ? remaining : totalSeconds
    }

    private var displayTime: String {
        let t = displaySeconds
        return String(format: "%02d:%02d", t / 60, t % 60)
    }

    private var canEdit: Bool { !running }

    var body: some View {
        VStack(spacing: 12) {
            Text("Timer")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.top, 12)

            // Time display - click to edit
            ZStack {
                if editing {
                    TextField("MM:SS", text: $draft)
                        .textFieldStyle(.plain)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .frame(width: 170, height: 58)
                        .focused($fieldFocused)
                        .onSubmit { commitEdit() }
                        .onChange(of: fieldFocused) { _, isFocused in
                            if !isFocused { commitEdit() }
                        }
                        .onAppear {
                            draft = displayTime
                            fieldFocused = true
                        }
                        .onExitCommand { cancelEdit() }
                } else {
                    Text(displayTime)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(finished ? .red : .primary)
                        .frame(width: 170, height: 58)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if canEdit {
                                editing = true
                            }
                        }
                        .help(canEdit ? "Click to edit time" : "")
                }
            }
            .frame(height: 58)

            // Preset buttons
            HStack(spacing: 6) {
                ForEach(presets, id: \.self) { mins in
                    Button("\(mins)m") {
                        setPreset(mins)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(totalSeconds == mins * 60 && !running ? .accentColor : nil)
                }
            }

            // Controls
            HStack(spacing: 16) {
                if running {
                    Button("Stop") {
                        stopTimer()
                    }
                    .controlSize(.large)
                    .keyboardShortcut(.space, modifiers: [])
                } else {
                    Button(finished ? "Restart" : "Start") {
                        startTimer()
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.space, modifiers: [])

                    Button("Reset") {
                        resetTimer()
                    }
                    .controlSize(.large)
                }
            }
            .padding(.top, 4)
        }
    }

    private func parseTime(_ str: String) -> Int? {
        // Accept "MM:SS", "M:SS", or just a number (treated as minutes)
        let trimmed = str.trimmingCharacters(in: .whitespaces)
        if trimmed.contains(":") {
            let parts = trimmed.split(separator: ":")
            guard parts.count == 2,
                  let mins = Int(parts[0]),
                  let secs = Int(parts[1]),
                  mins >= 0, secs >= 0, secs < 60 else { return nil }
            return mins * 60 + secs
        } else if let n = Int(trimmed) {
            return n * 60 // bare number = minutes
        }
        return nil
    }

    private func commitEdit() {
        if let seconds = parseTime(draft) {
            totalSeconds = min(max(seconds, 1), 5400)
            remaining = totalSeconds
            finished = false
        }
        editing = false
    }

    private func cancelEdit() {
        editing = false
    }

    private func setPreset(_ mins: Int) {
        stopTimer()
        editing = false
        totalSeconds = mins * 60
        remaining = totalSeconds
        finished = false
    }

    private func startTimer() {
        editing = false
        if finished || remaining <= 0 {
            remaining = totalSeconds
        }
        if totalSeconds == 0 { return }
        finished = false
        running = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remaining > 0 {
                remaining -= 1
            }
            if remaining == 0 {
                stopTimer()
                finished = true
                playAlarm()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        running = false
    }

    private func resetTimer() {
        stopTimer()
        editing = false
        remaining = totalSeconds
        finished = false
    }

    private func playAlarm() {
        Task {
            for _ in 0..<3 {
                NSSound.beep()
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }
}
