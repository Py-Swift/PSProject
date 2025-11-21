//
//  Template.swift
//  PSProject
//
import ArgumentParser
import XcodeProjectBuilder
import PathKit
import Backends
import PSTools
import PyProjectToml

extension PSProject {
    
    
    struct Template: AsyncParsableCommand {
        public static let configuration: CommandConfiguration = .init(
            subcommands: [
                Package.self
            ]
        )
        
    }
    
}
