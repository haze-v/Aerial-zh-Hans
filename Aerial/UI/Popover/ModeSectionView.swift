//
//  ModeSectionView.swift
//  Aerial Companion
//
//  Created by Guillaume Louel on 19/01/2026.
//

import SwiftUI

/// Top row with two equal mode buttons: Screensaver and Wallpaper.
struct ModeSectionView: View {
    @ObservedObject var playbackManager: PlaybackManager
    var onDismiss: () -> Void

    /// Source of truth for "is the wallpaper extension running" (drives the
    /// wallpaper button's play/pause vs. guide-to-Settings state).
    @ObservedObject private var statusMonitor = WallpaperStatusMonitor.shared

    /// User pause intent mirrored from WallpaperControl (not observable);
    /// refreshed on appear and on every status echo.
    @State private var wallpaperPaused = WallpaperControl.shared.currentPaused

    private func reloadPause() {
        wallpaperPaused = WallpaperControl.shared.currentPaused
    }

    var body: some View {
        HStack(spacing: 8) {
            // Screensaver button — starts the OS screensaver now (which
            // renders Aerial via the wallpaper extension's idle mode).
            Button(action: {
                playbackManager.startScreensaver()
                onDismiss()
            }) {
                modeLabel(icon: "lock.display", title: "Screensaver")
            }
            .buttonStyle(.plain)
            .help("Start the screensaver now")

            // Wallpaper button.
            wallpaperButton
        }
        .onAppear(perform: reloadPause)
        .onReceive(statusMonitor.$status) { _ in reloadPause() }
    }

    /// Pause or resume the desktop wallpaper on every display.
    private var wallpaperButton: some View {
        Button(action: {
            if statusMonitor.isRunning {
                let control = WallpaperControl.shared
                control.setPaused(!control.currentPaused)
                reloadPause()
            } else {
                _ = Helpers.shell(launchPath: "/usr/bin/open", arguments: [
                    "x-apple.systempreferences:com.apple.Wallpaper-Settings.extension"
                ])
            }
            onDismiss()
        }) {
            modeLabel(
                icon: wallpaperButtonIcon,
                title: wallpaperButtonTitle,
                isActive: statusMonitor.isRunning && !wallpaperPaused,
                stopWhenActive: false
            )
        }
        .buttonStyle(.plain)
        .help(LocalizedStringKey(wallpaperButtonHelp))
    }

    private var wallpaperButtonIcon: String {
        if !statusMonitor.isRunning { return "menubar.dock.rectangle" }
        return wallpaperPaused ? "play.fill" : "pause.fill"
    }

    private var wallpaperButtonTitle: String {
        if !statusMonitor.isRunning { return "Wallpaper" }
        return wallpaperPaused ? "Resume all wallpapers" : "Pause all wallpapers"
    }

    private var wallpaperButtonHelp: String {
        if !statusMonitor.isRunning {
            return "Choose Aerial 4 in System Settings → Wallpaper to use the live wallpaper"
        }
        return wallpaperButtonTitle
    }

    private func modeLabel(
        icon: String,
        title: String,
        isActive: Bool = false,
        stopWhenActive: Bool = true
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: (isActive && stopWhenActive) ? "stop.fill" : icon)
                .font(.system(size: 20, weight: .semibold))
            Text(LocalizedStringKey(title))
                .font(.body)
        }
        .foregroundColor(.aerial)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        // minHeight (not exact height) lets the button grow under Dynamic
        // Type while keeping the two siblings on a shared baseline.
        .frame(minHeight: 64)
        .background(Color.aerial.opacity(isActive ? 0.25 : 0.1))
        .cornerRadius(8)
        .contentShape(Rectangle())
    }
}

struct ModeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSectionView(
            playbackManager: PlaybackManager.shared,
            onDismiss: {}
        )
        .padding()
        .frame(width: 380)
    }
}
