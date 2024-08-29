import Foundation
import Testing

/// Cache of the test bundle URL.
private let cachedBundleURL: URL = initCachedURL()

/// Work out the bundle URL.
/// - Returns: The URL of the test bundle.
///
/// We look for the test bundle by looking at the command line arguments.
/// We assume that the test bundle is the first argument that contains ".xctest".
private func initCachedURL() -> URL {
  for arg in ProcessInfo.processInfo.arguments {
    if arg.contains(".xctest") {
      if let path = arg.split(separator: ".xctest").first {
        return URL(fileURLWithPath: String(path))
      }
    }
  }

  fatalError("Could not find the test bundle path")
}

extension Test {
  /// URL of the test bundle.
  var bundleURL: URL { cachedBundleURL }

  /// URL of the build folder that contains the test bundle.
  /// It may also contain other build products that we want to access,
  /// such as a command line tool we are testing.
  var buildFolderURL: URL {
    return bundleURL.deletingLastPathComponent()
  }

  /// URL to a named tool.
  /// - Parameter name: The name of the tool.
  /// - Returns: The URL of the tool.
  ///
  /// We look for the tool in the test bundle's location first,
  /// in case we built it. If it's not there, we look in the system path.
  func urlForTool(_ name: String) -> URL {
    // look in the test bundle's location first
    // in case we built the tool
    let local =
      buildFolderURL
      .appendingPathComponent(name)
    if FileManager.default.fileExists(atPath: local.path) {
      return local
    }

    return URL(inSystemPathWithName: name, fallback: "/usr/local/bin/\(name)")
  }

  /// Make a temporary folder for testing, and run some code in it.
  ///
  /// - Parameter body: The code to run in the temporary folder.
  /// - Returns: The result of the code.
  ///
  /// The temporary folder is deleted after the code runs.
  func inTempFolder<T>(_ body: (URL) async throws -> T) async throws -> T {
    let temp = URL(fileURLWithPath: NSTemporaryDirectory())
    let folder = temp.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    defer {
      try? FileManager.default.removeItem(at: folder)
    }

    return try await body(folder)
  }
}
