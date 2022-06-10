// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner

@main struct VersionatorTool {
    static func main() {
        guard CommandLine.arguments.count == 4 else {
            fatalError("wrong arguments passed to tool \(CommandLine.arguments)")
        }
                       
        let root = CommandLine.arguments[1]
        chdir(root)
        
        let runner = Runner(command: "git")
        let buildNumber: String
        do {
            let result = try runner.sync(arguments: ["rev-list", "--count", "HEAD"])
            buildNumber = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            buildNumber = "0"
        }

        let commit: String
        do {
            let result = try runner.sync(arguments: ["rev-list", "--max-count", "1", "HEAD"])
            commit = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            commit = ""
        }

        let gitVersion: String
        do {
            let result = try runner.sync(arguments: ["describe", "--always"])
            gitVersion = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            gitVersion = ""
        }

        let generatedSwift = """
        public struct CurrentVersion {
            static let build: Int = \(buildNumber)
            static let commit: String = "\(commit)"
            static let git: String = "\(gitVersion)"
        }
        """
        
        let path = CommandLine.arguments[2]
        let data = generatedSwift.data(using: .utf8)
        let outputURL = URL(fileURLWithPath: path)
        try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data?.write(to: outputURL)

        let infoPath = CommandLine.arguments[3]
        let info = [
            "CFBundleVersion": buildNumber,
            "Commit": commit,
            "CFBundleShortVersionString": gitVersion,
            "CFBundleInfoDictionaryVersion": 6.0
        ] as NSDictionary
        
        let infoData = try? PropertyListSerialization.data(fromPropertyList: info, format: .binary, options: 0)
        let infoURL = URL(fileURLWithPath: infoPath)
        try? infoData?.write(to: infoURL)

    }
}
