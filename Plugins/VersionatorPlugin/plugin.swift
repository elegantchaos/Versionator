// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackagePlugin

@main struct VersionatorPlugin: BuildToolPlugin {
  func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
    // generate the swift and header files
    var filesToGenerate = ["Version.generated.swift", "Info.plisth"]
    if target.hasResources {
      // if the target has resources, also generate an Info.plist
      filesToGenerate.append("Info.plist")
    }

    // calculate the paths to the generated files
    // we delete any existing versions to ensure that they're always regenerated
    let generatedFolderPath = context.pluginWorkDirectory.appending("GeneratedSources")
    var outputFiles: [Path] = []
    for file in filesToGenerate {
      let path = generatedFolderPath.appending(file)
      outputFiles.append(path)
      try? FileManager.default.removeItem(atPath: path.string)
    }

    var arguments = [context.package.directory]
    arguments.append(contentsOf: outputFiles)

    return [
      .buildCommand(
        displayName: "Calculating Version",
        executable: try context.tool(named: "VersionatorTool").path,
        arguments: arguments,
        outputFiles: outputFiles
      )
    ]
  }
}

let nonResourceExtensions = ["swift", "h", "c", "m", "cp", "cpp", "hp", "hpp"]

extension PackagePlugin.Target {

  /// Does the target include resources?
  /// Ideally we'd just be able to access the `resources:` information for the target,
  /// but is seems not to be possible currently. As an approximation, we check to see
  /// if the source files contains anything with a non-source extension.
  var hasResources: Bool {
    guard let sourceTarget = self as? SourceModuleTarget else { return false }
    return sourceTarget.sourceFiles.contains { file in
      guard let ext = file.path.extension else { return false }
      return !nonResourceExtensions.contains(ext)
    }
  }
}
