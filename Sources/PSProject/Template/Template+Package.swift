//
//  Template+Package.swift
//  PSProject
//

import ArgumentParser
import PSTools
import PathKit
import TemplateGenerator


extension PSProject.Template {
    
    struct Package: AsyncParsableCommand {
        
        @Argument var name: String
        @Option var resource: [Path] = []
        
        func run() async throws {
            try PackageTemplate(
                name: name,
                resources: resource.map(\.string),
                root: .current
            ).generate()
        }
    }
    
}

