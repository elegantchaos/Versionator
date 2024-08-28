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
    let output = try runner.run(arguments: ["./", folder.appending(component: "Version.swift").path])
    print(await String(output.stdout))
  }
}
