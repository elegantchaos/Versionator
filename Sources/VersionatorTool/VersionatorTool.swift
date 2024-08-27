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
          Usage: \(name) <input-path> <output-path> {<info-path>} {<header-path>}
          
          Calculates the "version" of the git repo at <input-path>, 
          and writes a generated Swift file to <output-path>.

          Optionally also writes an generated plist file to <info-path>, and
          a C-style header file to <header-path>.
        """)

      exit(1)
    }

    let root = args[1]
    chdir(root)

    let runner = Runner(command: "git")

    // build number is derived from the commit count on the current branch
    let buildNumber: String
    do {
      let result = try runner.run(arguments: ["rev-list", "--count", "HEAD"])
      buildNumber = await String(result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)

    } catch {
      buildNumber = "unknown"
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

    writeSwift(to: args[2], version: version, commit: commit, tag: tag, buildNumber: buildNumber, gitVersion: gitVersion)
    if args.count > 3 {
      writePlist(to: args[3], buildNumber: buildNumber, commit: commit, gitVersion: gitVersion)
    }
    if args.count > 4 {
      writeHeader(to: args[4], version: version, commit: commit, tag: tag, buildNumber: buildNumber, gitVersion: gitVersion)
    }

  }

  /// Write out the generated Swift.
  static func writeSwift(to path: String, version: String.SubSequence, commit: String.SubSequence, tag: String.SubSequence, buildNumber: String, gitVersion: String) {
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
    let data = generatedSwift.data(using: .utf8)
    var outputURL = URL(fileURLWithPath: path)
    if outputURL.pathExtension == "" {
      outputURL = outputURL.appendingPathExtension("swift")
    }
    try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? data?.write(to: outputURL)
  }

  static func writeHeader(to path: String, version: String.SubSequence, commit: String.SubSequence, tag: String.SubSequence, buildNumber: String, gitVersion: String) {
    let generatedHeader = """
      #define BUILD \(buildNumber)
      #define CURRENT_PROJECT_VERSION \(buildNumber)
      #define COMMIT \(commit)
      #define GIT_VERSION "\(gitVersion)"
      #define GIT_TAG "\(tag)"
      """
    let data = generatedHeader.data(using: .utf8)
    var outputURL = URL(fileURLWithPath: path)
    if outputURL.pathExtension == "" {
      outputURL = outputURL.appendingPathExtension("h")
    }
    try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? data?.write(to: outputURL)
  }

  /// Write out the generate Plist
  static func writePlist(to infoPath: String, buildNumber: String, commit: String.SubSequence, gitVersion: String) {
    let info =
      [
        "CFBundleVersion": buildNumber,
        "Commit": commit,
        "CFBundleShortVersionString": gitVersion,
        "CFBundleInfoDictionaryVersion": 6.0,
      ] as NSDictionary

    let infoData = try? PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
    var infoURL = URL(fileURLWithPath: infoPath)
    if infoURL.pathExtension == "" {
      infoURL = infoURL.appendingPathExtension("plist")
    }
    try? infoData?.write(to: infoURL)
  }
}
