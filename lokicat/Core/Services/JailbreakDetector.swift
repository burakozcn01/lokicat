import Foundation
import UIKit

final class JailbreakDetector {
    static let shared = JailbreakDetector()

    private init() {}

    var isJailbroken: Bool {
        checkSuspiciousFiles() || checkSuspiciousApps() || checkWriteAccess()
    }

    private func checkSuspiciousFiles() -> Bool {
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/Applications/blackra1n.app",
            "/Applications/FakeCarrier.app",
            "/Applications/Icy.app",
            "/Applications/IntelliScreen.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/SBSettings.app",
            "/Applications/WinterBoard.app"
        ]

        for path in suspiciousPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        return false
    }

    private func checkSuspiciousApps() -> Bool {
        guard let cydiaUrl = URL(string: "cydia://package/com.example.package") else {
            return false
        }
        return UIApplication.shared.canOpenURL(cydiaUrl)
    }

    private func checkWriteAccess() -> Bool {
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }
}
