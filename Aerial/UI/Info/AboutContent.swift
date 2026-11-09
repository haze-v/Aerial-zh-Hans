//
//  AboutContent.swift
//  Aerial Companion
//
//  Single source of truth for the "About Aerial" surface. Used by:
//   - `InfoWindowController` (the standalone About window opened from
//     the popover's info-circle button).
//   - `AboutSettingsPanel` (the About entry in Settings; this view sits
//     inside its "About Aerial" GroupBox).
//
//  Vertical centered hero: icon → title → version → description →
//  Website / Discord row → tiny
//  Inferno design credit footer.
//

import SwiftUI
import AppKit

struct AboutContent: View {
    /// Shared with the Help menu (`AerialCommands`).
    enum AboutLinks {
        static let website   = URL(string: "https://aerialscreensaver.github.io/")!
        static let discord   = URL(string: "https://discord.gg/TPuA5WG")!
        static let inferno   = URL(string: "https://infernodesign.com")!
    }

    /// Pulled live so the same view shows up correctly in InfoView's
    /// hosting controller AND in the Settings panel.
    private var versionLine: String {
        let marketing = Helpers.version
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return String(localized: "Version \(marketing) (\(build))")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 128, height: 128)

            VStack(spacing: 4) {
                Text("Aerial")
                    .font(.system(size: 32, weight: .bold))
                Text(versionLine)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Text("A free, open-source macOS screen saver and video wallpaper app, made and maintained by Guillaume Louel.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)

            VStack(spacing: 8) {
                Text("Looking for support?")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button {
                        NSWorkspace.shared.open(AboutLinks.website)
                    } label: {
                        Label("Website", systemImage: "globe")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button {
                        NSWorkspace.shared.open(AboutLinks.discord)
                    } label: {
                        Label("Discord", systemImage: "message")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }

            Link("Icon by Inferno design", destination: AboutLinks.inferno)
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 380)
    }

}

struct AboutContent_Previews: PreviewProvider {
    static var previews: some View {
        AboutContent()
    }
}
