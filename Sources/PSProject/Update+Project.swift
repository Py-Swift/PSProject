//
//  Update+Project.swift
//  PSProject
//
import ArgumentParser
import PathKit
import PSTools
import Backends
import PyProjectToml

extension PSProject.Update {
    struct Project: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration {
            .init(
                abstract: abstractInfo,
            )
        }
        
        @Argument var uv: Path?
        
        func run() async throws {
            
            print(infoTitle(title: "Updating Project"))
            
            let root = uv ?? .current
            Path.setPSShared(root)
            //if !Validation.hostPython() { return }
            try Validation.backends()
            
            
            
            try await PSProject.Update.updateProject(uv: root)
            
        }
    }
    
    
    static func updateProject(uv: Path) async throws {
        let uv_abs = uv.absolute()
        let toml_path = (uv_abs + "pyproject.toml")
        let toml = try toml_path.loadPyProjectToml()
        
        guard let proj = toml.tool?.psproject else {
            fatalError("tool.psproject in pyproject.toml not found")
        }
        
        
    }
}

