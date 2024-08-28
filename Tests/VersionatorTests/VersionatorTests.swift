import Foundation
import Testing
import VersionatorUtils

@testable import Runner

/// Test with a task that has a zero status.
@Test func testTool() async throws {
  let runner = Runner(command: "pwd")
  let output = try runner.run()
  print(await String(output.stdout))
  for await state in output.state {
    print(state)
  }
  //   for item in ProcessInfo.processInfo.environment {
  //     print("\(item.key): \(item.value)")
  //   }
  for arg in ProcessInfo.processInfo.arguments {
    if arg.contains(".xctest") {
      if let path = arg.split(separator: ".xctest").first {
        let url = URL(fileURLWithPath: String(path))
        print(url)
      }

    }
  }
}
