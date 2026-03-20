//
//  Init.swift
//  PSProject
//
import ArgumentParser
import PathKit
import TOMLKit
import PyProjectToml
import PSTools

extension PSProject {
    struct Init: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration {
            .init(
                abstract: abstractInfo,
            )
        }
        
        @Option var path: Path?
        @Option var name: String?
        @Option var buildozer: Path?
        @Flag var cythonized: Bool = false
        @Option var backend: [String] = []
        
        
        
        func run() async throws {
            
            //if !Validation.hostPython() { return }
            let root = path ?? .current
            Path.setPSShared(root)
            
            let btoml: TOMLTable? = if let buildozer {
                try BuildozerSpecReader(path: buildozer).export()
            } else { nil }
            let buildozer_app = btoml?["buildozer-app"]?.table
            let uv_name = name ?? buildozer_app?["package"]?["name"]?.string
            
            
            try await PyProjectToml.newToml(
                path: root,
                app_name: name,
                cythonized: cythonized,
                executedByUV: path == nil,
                backends: backend
            )
            
        }
        
        
        
        
    }
}

