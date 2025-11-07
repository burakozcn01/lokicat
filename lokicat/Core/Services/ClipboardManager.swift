import Foundation
import UIKit

final class ClipboardManager {
    static let shared = ClipboardManager()

    private var clearTimer: Timer?
    private let defaultClearDelay: TimeInterval = 30

    private init() {}

    func scheduleClipboardClear(after delay: TimeInterval? = nil) {
        clearTimer?.invalidate()

        let clearDelay = delay ?? defaultClearDelay

        clearTimer = Timer.scheduledTimer(withTimeInterval: clearDelay, repeats: false) { [weak self] _ in
            self?.clearClipboard()
        }
    }

    private func clearClipboard() {
        UIPasteboard.general.string = ""
    }

    func cancelScheduledClear() {
        clearTimer?.invalidate()
        clearTimer = nil
    }
}
