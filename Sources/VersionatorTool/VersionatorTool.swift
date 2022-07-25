// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner

@main struct VersionatorTool {
    static func main() {
        let all = ProcessInfo.processInfo.arguments
        let args = all.filter({ !$0.starts(with: "--") })
        guard args.count > 2 else {
            let name = URL(fileURLWithPath: args[0]).lastPathComponent
            print("\n\nUsage: \(name) <options> <root> <path> {<infoPath>}")
            exit(1)
        }

        print(all)
        print("[error]: test")
        print("[warning]: test")
        print("[note]: test")
//        let options = Set(all.filter({ $0.starts(with: "--") }))

        let root = args[1]
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
        
        let path = args[2]
        let data = generatedSwift.data(using: .utf8)
        let outputURL = URL(fileURLWithPath: path)
        try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data?.write(to: outputURL)

        if args.count > 3 {
            let infoPath = args[3]
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
}
