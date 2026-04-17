//
//  Gradle.swift
//  PSProject
//
import Foundation
import ArgumentParser
import PathKit
import PSTools
import GradleProjectBuilder

extension PSProject.Create {
    
    struct Gradle: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration {
            .init(abstract: abstractInfo)
        }
        
        @Option var directory: Path?
        
        @Option(name: .long, help: "Android architectures to build for (comma-separated: arm64-v8a,x86_64)")
        var arch: String = "arm64-v8a,x86_64"
        
        @MainActor
        func run() async throws {
            let root = directory ?? .current
            
            try Validation.pyprojectExist(root: root)
            
            let archs = arch.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            
            try await GradleProjectBuilder.create(uv: root, archs: archs)
        }
    }
    
}
