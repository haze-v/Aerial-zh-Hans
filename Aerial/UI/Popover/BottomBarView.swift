//
//  BottomBarView.swift
//  Aerial Companion
//
//  Created by Guillaume Louel on 19/01/2026.
//

import Combine
import SwiftUI

/// Bottom bar with info, settings, help buttons and version label
struct BottomBarView: View {
    @Environment(\.openWindow) private var openWindow

    let version: String
    var onOpenInfo: () -> Void
    /// Called *after* the Video Library window is opened so the
    /// AppDelegate can dismiss the surrounding popover. The window
    /// itself is opened in-place via `@Environment(\.openWindow)`.
    var onOpenVideoBrowser: () -> Void
    var onOpenSettings: () -> Void
    var onExit: () -> Void

    /// Restart chip (Settings → Wallpaper → Troubleshooting).
    /// Seeded on every popover open — the whole popover tree is
    /// dismounted while closed — and live-updated via the pref
    /// notification for the rare open-while-toggling case.
    @State private var showRestartButton = Preferences.showRestartWallpaperButton
    @State private var isRestarting = false

    @State private var showingMore = false
    @State private var viewingMode = PrefsDisplays.viewingMode
    @State private var autoPauseThreshold = Preferences.desktopAutoPauseThreshold
    @State private var cpuThreshold = Preferences.desktopCPUThreshold
    @AppStorage("randomVideoHistoryPercent") private var randomVideoHistoryPercent: Double = 75
    @State private var screenCoverages: [ScreenCoverageInfo] = []
    @State private var coverageTimer: AnyCancellable?

    var body: some View {
        VStack(spacing: 8) {
            toolbar
            if showingMore {
                moreControls
            }
        }
        .padding(.top, 8)
        .onReceive(NotificationCenter.default.publisher(for: .showRestartWallpaperButtonDidChange)) { notification in
            showRestartButton = (notification.object as? Bool) ?? Preferences.showRestartWallpaperButton
        }
        .onDisappear {
            coverageTimer?.cancel()
            coverageTimer = nil
        }
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            // Info button
            Button(action: onOpenInfo) {
                chipLabel(icon: "info.circle")
            }
            .buttonStyle(.plain)
            .help("About Aerial")
            .accessibilityLabel("About Aerial")

            // Settings button
            Button(action: {
                SettingsWindowController.show(via: openWindow)
                onOpenSettings()
            }) {
                chipLabel(icon: "gear")
            }
            .buttonStyle(.plain)
            .help("Settings")
            .accessibilityLabel("Settings")
            .keyboardShortcut(",", modifiers: .command)

            // Video Browser button
            Button(action: {
                VideoBrowserWindowController.show(via: openWindow)
                onOpenVideoBrowser()
            }) {
                chipLabel(icon: "film.stack")
            }
            .buttonStyle(.plain)
            .help("Video Library")
            .accessibilityLabel("Video Library")

            Spacer()

            // Version label
            Text(version)
                .font(.title3).bold()
                .foregroundStyle(.tertiary)

            Spacer()

            Button {
                viewingMode = PrefsDisplays.viewingMode
                autoPauseThreshold = Preferences.desktopAutoPauseThreshold
                cpuThreshold = Preferences.desktopCPUThreshold
                showingMore.toggle()
                if showingMore {
                    refreshScreenCoverages()
                    coverageTimer = Timer.publish(every: 2.0, on: .main, in: .common)
                        .autoconnect()
                        .sink { _ in refreshScreenCoverages() }
                } else {
                    coverageTimer?.cancel()
                    coverageTimer = nil
                }
            } label: {
                Label("More", systemImage: showingMore ? "chevron.up" : "ellipsis")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.aerial)
                    .padding(.horizontal, 8)
                    .frame(height: 28)
                    .background(Color.aerial.opacity(0.1))
                    .cornerRadius(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var moreControls: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text("Viewing mode")
                    .font(.system(size: 12))
                DashboardModeSwitcher(current: viewingMode) { mode in
                    PlaybackManager.shared.changeViewingMode(mode)
                    viewingMode = PrefsDisplays.viewingMode
                }
                .accessibilityLabel("Viewing mode")

                Spacer(minLength: 0)

                if showRestartButton {
                    Button(action: restartWallpaperAgent) {
                        chipLabel(icon: "arrow.clockwise", iconSize: 16, width: 32, height: 28)
                    }
                    .buttonStyle(.plain)
                    .disabled(isRestarting)
                    .opacity(isRestarting ? 0.5 : 1)
                    .help("Restart the wallpaper agent")
                    .accessibilityLabel("Restart Wallpaper Agent")
                }

                Button(action: onExit) {
                    chipLabel(icon: "xmark.circle", iconSize: 16, width: 32, height: 28)
                }
                .buttonStyle(.plain)
                .help("Quit Aerial")
                .accessibilityLabel("Quit Aerial")
            }

            HStack(spacing: 8) {
                Text("Coverage threshold")
                    .font(.system(size: 12))
                Slider(value: $autoPauseThreshold, in: 0.3...0.9, step: 0.05)
                    .accessibilityLabel("Coverage threshold")
                    .help("Pause playback when this percentage of the screen is covered by windows. Lower values pause sooner.")
                    .onChange(of: autoPauseThreshold) { newValue in
                        Preferences.desktopAutoPauseThreshold = newValue
                    }
                Text("\(Int((autoPauseThreshold * 100).rounded()))%")
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
                    .frame(width: 38, alignment: .trailing)
            }

            HStack(spacing: 8) {
                Text("骰子防重复范围")
                    .font(.system(size: 12))
                Slider(value: $randomVideoHistoryPercent, in: 0...100, step: 5)
                    .accessibilityLabel("骰子防重复范围")
                Text("\(Int(randomVideoHistoryPercent))%")
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
                    .frame(width: 38, alignment: .trailing)
            }

            HStack(spacing: 8) {
                Text("CPU threshold")
                    .font(.system(size: 12))
                Slider(value: $cpuThreshold, in: 5...95, step: 5)
                    .accessibilityLabel("CPU threshold")
                    .onChange(of: cpuThreshold) { _, threshold in
                        Preferences.desktopCPUThreshold = threshold
                        WallpaperAutoPauseCoordinator.shared.reevaluate()
                    }
                Text("\(Int(cpuThreshold))%")
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
                    .frame(width: 38, alignment: .trailing)
            }

            if !screenCoverages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Text("遮挡")
                        ForEach(screenCoverages) { screen in
                            Text("· \(screen.name) \(Int((screen.coverage * 100).rounded()))%")
                        }
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }
            }
        }
    }

    private func refreshScreenCoverages() {
        let displays = NSScreen.screens.enumerated().compactMap { (index, screen) -> (Int, CGDirectDisplayID)? in
            guard let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
                return nil
            }
            return (index, displayID)
        }
        let externalCount = displays.filter { CGDisplayIsBuiltin($0.1) == 0 }.count
        var externalIndex = 0
        let screens = displays.map { index, displayID -> (Int, String, CGDirectDisplayID) in
            if CGDisplayIsBuiltin(displayID) != 0 {
                return (index, "内屏", displayID)
            }
            externalIndex += 1
            let name = externalCount == 1 ? "外屏" : "外屏\(externalIndex)"
            return (index, name, displayID)
        }
        DispatchQueue.global(qos: .utility).async {
            let frames = Dictionary(uniqueKeysWithValues: screens.map { (String($0.2), CGDisplayBounds($0.2)) })
            let coverages = DesktopOcclusionMonitor.coverages(for: frames)
            let results = screens.map { index, name, displayID in
                ScreenCoverageInfo(id: index, name: name, coverage: coverages[String(displayID)] ?? 0)
            }
            DispatchQueue.main.async {
                guard showingMore else { return }
                screenCoverages = results
            }
        }
    }

    private func restartWallpaperAgent() {
        Task { @MainActor in
            isRestarting = true
            await WallpaperExtensionHealth.restartAgentAndReload(reason: "Menu bar button")
            isRestarting = false
        }
    }

    private func chipLabel(icon: String, iconSize: CGFloat = 22, width: CGFloat = 44, height: CGFloat = 36) -> some View {
        Image(systemName: icon)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundColor(.aerial)
            .frame(width: width, height: height)
            .background(Color.aerial.opacity(0.1))
            .cornerRadius(8)
            .contentShape(Rectangle())
    }
}

struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView(
            version: "3.5",
            onOpenInfo: {},
            onOpenVideoBrowser: {},
            onOpenSettings: {},
            onExit: {}
        )
        .padding()
        .frame(width: 380)
    }
}
