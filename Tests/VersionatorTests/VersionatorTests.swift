import Foundation
import Runner
import Testing
import VersionatorUtils

@testable import Runner

/// Run the versionator tool over the example repo, and check that it generates the expected files,
/// with the expected content.
@Test func testTool() async throws {
  let test = Test.current!
  try await test.inTempFolder { folder in
    let fm = FileManager.default

    // copy example repo into temp folder
    let exampleRepo = Bundle.module.url(forResource: "Example", withExtension: "git")!
    let repoFolder = folder.appending(path: "Example.git")
    try fm.copyItem(at: exampleRepo, to: repoFolder)

    // rename .git folder inside repo
    try fm.moveItem(at: repoFolder.appending(path: "git"), to: repoFolder.appending(path: ".git"))

    // run the tool over the repo
    let url = test.urlForTool("VersionatorTool")
    let runner = Runner(for: url, cwd: repoFolder)
    let files = ["Version.swift", "Version.plist", "Version.h", "Info.plisth"]
    var args = ["--verbose", "./"]
    let paths = files.map { folder.appending(component: $0) }
    args.append(contentsOf: paths.map { $0.path })
    let output = await runner.run(args)
      .stdout.string

    // check generated files were logged to output
    #expect(output.contains("Generated Version.swift"))
    #expect(output.contains("Generated Version.h"))
    #expect(output.contains("Generated Version.plist"))
    #expect(output.contains("Generated Info.plisth"))

    // check generated content matches expected
    for url in paths {
      let expectedURL = Bundle.module.url(forResource: "Example.out/\(url.deletingPathExtension().lastPathComponent)", withExtension: url.pathExtension)!
      if url.pathExtension != "plist" {
        let content = try String(contentsOf: url, encoding: .utf8)
        let expected = try String(contentsOf: expectedURL, encoding: .utf8)
        for (c, e) in zip(content.split(separator: "\n"), expected.split(separator: "\n")) {
          #expect(c == e, "content does not match expected for \(url.lastPathComponent)")
        }
      } else {
        #expect(NSDictionary(contentsOf: url) == NSDictionary(contentsOf: expectedURL), "content does not match expected for \(url.lastPathComponent)")
      }
    }
  }
}
