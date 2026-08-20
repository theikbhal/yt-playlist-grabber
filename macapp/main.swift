import AppKit
import Foundation
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var urlField: NSTextField!
    var outputView: NSTextView!
    var statusLabel: NSTextField!

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildUI()
    }

    private func buildUI() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 560),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        window.title = "Playlist Grabber"
        window.center()

        let content = NSView(frame: NSRect(x: 0, y: 0, width: 760, height: 560))

        let title = NSTextField(labelWithString: "YouTube Playlist Grabber")
        title.font = NSFont.boldSystemFont(ofSize: 20)
        title.frame = NSRect(x: 20, y: 520, width: 400, height: 28)
        content.addSubview(title)

        let urlLabel = NSTextField(labelWithString: "Playlist URL:")
        urlLabel.frame = NSRect(x: 20, y: 475, width: 90, height: 20)
        content.addSubview(urlLabel)

        urlField = NSTextField(frame: NSRect(x: 115, y: 470, width: 620, height: 26))
        urlField.placeholderString = "https://www.youtube.com/playlist?list=..."
        content.addSubview(urlField)

        let fetchButton = NSButton(title: "Fetch Videos", target: self, action: #selector(fetchClicked))
        fetchButton.frame = NSRect(x: 115, y: 428, width: 160, height: 32)
        content.addSubview(fetchButton)

        let copyButton = NSButton(title: "Copy Results", target: self, action: #selector(copyClicked))
        copyButton.frame = NSRect(x: 300, y: 428, width: 130, height: 32)
        content.addSubview(copyButton)

        let exportButton = NSButton(title: "Export Markdown…", target: self, action: #selector(exportClicked))
        exportButton.frame = NSRect(x: 455, y: 428, width: 160, height: 32)
        content.addSubview(exportButton)

        let scroll = NSScrollView(frame: NSRect(x: 20, y: 30, width: 720, height: 380))
        outputView = NSTextView(frame: NSRect(x: 0, y: 0, width: 720, height: 380))
        outputView.isEditable = false
        outputView.isRichText = true
        outputView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        scroll.documentView = outputView
        scroll.hasVerticalScroller = true
        content.addSubview(scroll)

        statusLabel = NSTextField(labelWithString: "Paste a URL and click Fetch Videos")
        statusLabel.frame = NSRect(x: 20, y: 6, width: 720, height: 16)
        statusLabel.textColor = .secondaryLabelColor
        content.addSubview(statusLabel)

        window.contentView = content
        window.makeFirstResponder(urlField)
        window.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func fetchClicked() {
        let url = urlField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !url.isEmpty else { return }
        statusLabel.stringValue = "Fetching…"
        outputView.string = ""
        fetchPlaylist(url) { [weak self] result in
            DispatchQueue.main.async {
                self?.statusLabel.stringValue = result
            }
        }
    }

    @objc private func copyClicked() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(outputView.string, forType: .string)
        statusLabel.stringValue = "Copied to clipboard"
    }

    @objc private func exportClicked() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "md")!]
        panel.nameFieldStringValue = "playlist.md"
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            do {
                try self?.outputView.string.write(to: url, atomically: true, encoding: .utf8)
                self?.statusLabel.stringValue = "Exported -> \(url.path)"
            } catch {
                self?.statusLabel.stringValue = "Export failed: \(error.localizedDescription)"
            }
        }
    }

    // Runs yt-dlp in the same process on a background queue
    private func fetchPlaylist(_ url: String, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["python3", self.cliPath(), url]
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                completion("Error: \(error.localizedDescription)")
                return
            }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let text = String(data: data, encoding: .utf8) ?? ""
            completion(text.isEmpty ? "No output" : text)
        }
    }

    private func cliPath() -> String {
        let candidates = [
            Bundle.main.bundlePath + "/Contents/Resources/fetch_playlist.py",
            CommandLine.arguments[0] + "/scripts/fetch_playlist.py",
        ]
        for c in candidates where FileManager.default.fileExists(atPath: c) { return c }
        // Fallback: same dir as this binary during development
        return "scripts/fetch_playlist.py"
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()