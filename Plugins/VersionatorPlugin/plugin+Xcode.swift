// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/08/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


#if canImport(XcodeProjectPlugin)

import Foundation
import PackagePlugin
import XcodeProjectPlugin

extension VersionatorPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [PackagePlugin.Command] {
        let generatedFolderPath = context.pluginWorkDirectory.appending("GeneratedSources")
        let generatedSwiftPath = generatedFolderPath.appending("Version.generated.swift")
        let root = context.xcodeProject.directory

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

extension XcodeProjectPlugin.XcodeTarget {
    
    /// Does the target include resources?
    /// Ideally we'd just be able to access the `resources:` information for the target,
    /// but is seems not to be possible currently. As an approximation, we check to see
    /// if the source files contains anything with a non-source extension.
    var hasResources: Bool {
        return inputFiles.contains { file in
            guard let ext = file.path.extension else { return false }
            return !nonResourceExtensions.contains(ext)
        }
    }
}

#endif


