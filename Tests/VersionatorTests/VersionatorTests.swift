import Foundation
import Runner
import Testing
import VersionatorUtils

@testable import Runner

/// Test with a task that has a zero status.
@Test func testTool() async throws {
  let test = Test.current!
  try await test.inTempFolder { folder in
    let url = test.urlForTool("VersionatorTool")
    let runner = Runner(for: url)
    let files = ["Version.swift", "Version.plist", "Version.h", "Info.plisth"]
    var args = ["--verbose", "./"]

    let paths = files.map { folder.appending(component: $0).path }
    args.append(contentsOf: paths)
    let output = await runner.run(args)
      .stdout.string

    #expect(output.contains("Generated Version.swift"))
    #expect(output.contains("Generated Version.h"))
    #expect(output.contains("Generated Version.plist"))
    #expect(output.contains("Generated Info.plisth"))
  }
}
