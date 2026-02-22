// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import XcodeProjectBuilder
import PathKit
import Backends
import PSTools
import PyProjectToml


@main
struct PSProject: AsyncParsableCommand {
    
    static var configuration: CommandConfiguration {
        .init(
            commandName: "psproject",
            version: LIBRARY_VERSION,
            subcommands: [
                Create.self,
                Init.self,
                Update.self,
                HostPython.self,
                Template.self
            ]
        )
    }
    
    
}



extension Path: ArgumentParser.ExpressibleByArgument {
    public init?(argument: String) {
        self.init(argument)
    }
}

extension Path: @retroactive Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(String.self))
    }
}
