// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner

@main struct VersionatorTool {
  static func main() async {
    let all = ProcessInfo.processInfo.arguments
    let args = all.filter({ !$0.starts(with: "--") })
    guard args.count > 2 else {
      let name = URL(fileURLWithPath: args[0]).lastPathComponent
      print(
        """
          Usage: \(name) <options> <input-path> <output-path> {<info-path>}
          
          Calculates the "version" of the git repo at <input-path>, 
          and writes a generated Swift file to <output-path>.

          Optionally also writes an Info.plist file to <info-path>. 
        """)

      exit(1)
    }

    //        let options = Set(all.filter({ $0.starts(with: "--") }))

    let root = args[1]
    chdir(root)

    let runner = Runner(command: "git")

    // build number is derived from the commit count on the current branch
    let buildNumber: String
    do {
      let result = try runner.run(arguments: ["rev-list", "--count", "HEAD"])
      buildNumber = await String(result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)

    } catch {
      buildNumber = "0"
    }

    let gitVersion: String
    do {
      let result = try runner.run(arguments: ["describe", "--long", "--tags", "--always"])
      gitVersion = await String(result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
      gitVersion = ""
    }

    let items = gitVersion.split(separator: "-")
    let tag = items.first ?? ""
    var version = tag
    if version.first == "v" { version.removeFirst() }
    let commit = items.count == 3 ? items[2] : ""

    let generatedSwift = """
      public struct CurrentVersion {
          static let string = "\(version)"
          static let build = \(buildNumber)
          static let commit = "\(commit)"
          static let git = "\(gitVersion)"
          static let tag = "\(tag)"
          static let full = "\(version) (\(buildNumber))"
      }
      """

    let path = args[2]
    let data = generatedSwift.data(using: .utf8)
    let outputURL = URL(fileURLWithPath: path)
    try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? data?.write(to: outputURL)

    if args.count > 3 {
      let infoPath = args[3]
      let info =
        [
          "CFBundleVersion": buildNumber,
          "Commit": commit,
          "CFBundleShortVersionString": gitVersion,
          "CFBundleInfoDictionaryVersion": 6.0,
        ] as NSDictionary

      let infoData = try? PropertyListSerialization.data(fromPropertyList: info, format: .binary, options: 0)
      let infoURL = URL(fileURLWithPath: infoPath)
      try? infoData?.write(to: infoURL)
    }

  }
}
