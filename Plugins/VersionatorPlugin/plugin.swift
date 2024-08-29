// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackagePlugin

@main struct VersionatorPlugin: BuildToolPlugin {
  func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
    // generate the swift and header files
    var filesToGenerate = ["Version.generated.swift"]
    if target.hasResources {
      // if the target has resources, also generate an Info.plist, and some C-style header definitions that could be used as a plist include.
      // (note, we don't use .h for the header file as SPM will treat it as code, and complain that it doesn't support mixed-language projects).
      filesToGenerate.append(contentsOf: ["Info.plist", "Info.plisth"])
    }

    // calculate the paths to the generated files
    // we delete any existing versions to ensure that they're always regenerated
    let generatedFolderPath = context.pluginWorkDirectoryURL.appending(path: "GeneratedSources")
    var outputFiles: [URL] = []
    for file in filesToGenerate {
      let url = generatedFolderPath.appending(path: file)
      outputFiles.append(url)
      try? FileManager.default.removeItem(atPath: url.path)
    }

    var arguments = [context.package.directoryURL.path]
    arguments.append(contentsOf: outputFiles.map { $0.path })

    return [
      .buildCommand(
        displayName: "Calculating Version",
        executable: try context.tool(named: "VersionatorTool").url,
        arguments: arguments,
        outputFiles: outputFiles
      )
    ]
  }
}

extension PackagePlugin.Target {
  /// Does the target include resources?
  var hasResources: Bool {
    guard let sourceTarget = self as? SourceModuleTarget else { return false }
    return sourceTarget.sourceFiles.contains { file in file.type == .resource }
  }
}
