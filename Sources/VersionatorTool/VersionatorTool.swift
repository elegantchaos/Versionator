// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner
import VersionatorUtils

@main struct VersionatorTool {
  static func main() async {
    let all = ProcessInfo.processInfo.arguments
    let args: [String] = all.filter({ !$0.starts(with: "--") })
    guard args.count > 2 else {
      let name = URL(fileURLWithPath: args[0]).lastPathComponent
      print(
        """
          Usage: {<options>} \(name) <path> {<path> ...}
          
          Calculates the "version" of the git repo at <input-path>, 
          and writes one or more generated files to the supplied paths.

          The file extension of each path determines the format. It can
          be one of: .swift, .plist, or .h.

          Options:
            --verbose: print out what's being generated.
        """)

      exit(1)
    }

    let options: [String] = all.filter({ $0.starts(with: "--") })
    let verbose = options.contains("--verbose")

    let root = args[1]
    chdir(root)

    let runner = Runner(command: "git")

    // build number is derived from the commit count on the current branch
    let buildNumber: String
    do {
      let result = try runner.run(["rev-list", "--count", "HEAD"])
      buildNumber = await String(result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)

    } catch {
      buildNumber = "unknown"
    }

    let gitVersion: String
    do {
      let result = try runner.run(["describe", "--long", "--tags", "--always"])
      gitVersion = await String(result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
      gitVersion = ""
    }

    let items = gitVersion.split(separator: "-")
    let tag = items.first ?? ""
    var version = tag
    if version.first == "v" { version.removeFirst() }
    let commit = items.count == 3 ? items[2] : ""

    for arg in args.dropFirst(2) {
      let url = URL(fileURLWithPath: arg)
      switch url.pathExtension {
      case "h", "plisth": writeHeader(to: url, version: version, commit: commit, tag: tag, buildNumber: buildNumber, gitVersion: gitVersion, verbose: verbose)
      case "swift": writeSwift(to: url, version: version, commit: commit, tag: tag, buildNumber: buildNumber, gitVersion: gitVersion, verbose: verbose)
      case "plist": writePlist(to: url, version: version, buildNumber: buildNumber, commit: commit, tag: tag, gitVersion: gitVersion, verbose: verbose)
      default: print("Unknown file type '\(url.pathExtension)'")
      }
    }
  }

  /// Write out the generated Swift.
  static func writeSwift(to url: URL, version: String.SubSequence, commit: String.SubSequence, tag: String.SubSequence, buildNumber: String, gitVersion: String, verbose: Bool) {
    let generatedSwift = """
      /// This file is generated by Versionator -- DO NOT EDIT.
      /// See github.com/elegantchaos/Versionator for more info.
      public struct VersionatorVersion {
          static let string = "\(version)"
          static let build = \(buildNumber)
          static let commit = "\(commit)"
          static let git = "\(gitVersion)"
          static let tag = "\(tag)"
          static let full = "\(version) (\(buildNumber))"
      }
      """
    let data = generatedSwift.data(using: .utf8)
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? data?.write(to: url)
    if verbose {
      print("Generated \(url.lastPathComponent) (to \(url.deletingLastPathComponent().path)).")
    }
  }

  static func writeHeader(to url: URL, version: String.SubSequence, commit: String.SubSequence, tag: String.SubSequence, buildNumber: String, gitVersion: String, verbose: Bool) {
    let generatedHeader = """
      /// This file is generated by Versionator -- DO NOT EDIT.
      /// See github.com/elegantchaos/Versionator for more info.
      #define BUILD \(buildNumber)
      #define CURRENT_PROJECT_VERSION \(buildNumber)
      #define COMMIT \(commit)
      #define GIT_VERSION "\(gitVersion)"
      #define GIT_TAG "\(tag)"
      """
    let data = generatedHeader.data(using: .utf8)
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? data?.write(to: url)
    if verbose {
      print("Generated \(url.lastPathComponent) (to \(url.deletingLastPathComponent().path)).")
    }
  }

  /// Write out the generate Plist
  /// Note that we use the binary format for the plist, because Swift's Bundle.module.infoDictionary
  /// support only seems to work for binary plists, not XML ones.
  static func writePlist(to url: URL, version: String.SubSequence, buildNumber: String, commit: String.SubSequence, tag: String.SubSequence, gitVersion: String, verbose: Bool) {
    let info =
      [
        "CFBundleVersion": buildNumber,
        "CFBundleShortVersionString": version,
        "CFBundleInfoDictionaryVersion": 6.0,
        "GitCommit": commit,
        "GitTag": tag,
        "GitVersion": gitVersion,
      ] as NSDictionary

    let infoData = try? PropertyListSerialization.data(fromPropertyList: info, format: .binary, options: 0)
    try? infoData?.write(to: url)
    if verbose {
      print("Generated \(url.lastPathComponent) (to \(url.deletingLastPathComponent().path)).")
    }
  }
}
