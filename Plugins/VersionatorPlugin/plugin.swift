// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackagePlugin

@main struct VersionatorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let generatedFolderPath = context.pluginWorkDirectory.appending("GeneratedSources")
        let generatedSwiftPath = generatedFolderPath.appending("Version.generated.swift")
        let root = context.package.directory

        var arguments = [root, generatedSwiftPath]
        var outputFiles = [generatedSwiftPath]
        
        if target.hasResources {
            let generatedPlistPath = generatedFolderPath.appending("Info.plist")
            arguments.append(generatedPlistPath)
            outputFiles.append(generatedPlistPath)
        }

        // TODO: make this a prebuild command when they work with local (non-binary) tool targets
        // as a temporary workaround, remove the generated folder to (hopefully?) force this to run every build
        let url = URL(fileURLWithPath: generatedFolderPath.string)
        try? FileManager.default.removeItem(at: url)
        
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
