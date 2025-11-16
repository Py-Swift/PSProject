//
//  YamlBackend.swift
//  Backends
//
import Foundation
import Yams
import ProjectSpec
import PathKit

extension SwiftPackage: Swift.Decodable {
    
    enum CodingKeys: CodingKey {
        
    }
    public init(from decoder: any Decoder) throws {
        
        
        fatalError()
    }
    
}

public final class YamlBackend: Decodable {
    
    let backend: Backend
    
    struct Backend: Decodable {
        let name: String
        let backend_dependencies: [String]?
        let frameworks: [String]?
        let packages: [String:SwiftPackage]?
    }
}

extension YamlBackend {
    class Script: Decodable {
        let type: ScriptType
    }
}

extension YamlBackend.Script {
    enum ScriptType: String, Decodable {
        case shell
    }
    enum ShellType: String, Decodable {
        case python
        case sh
        case bash
        case fish
        case ruby
    }
    enum Execution: Decodable {
        case file(String)
        case run(String)
    }
}

extension YamlBackend: BackendProtocol {
    
    public var name: String { backend.name }
    
    public func url() async throws -> URL? {nil}
    
    public func frameworks() async throws -> [Path] { [] }
    
    public func downloads() async throws -> [URL] { [] }
    
    public func config(root: Path) async throws { }
    
    public func packages() async throws -> [String:SwiftPackage] {
        [:]
    }
    
    public func target_dependencies(platform: ProjectSpec.Platform) async throws -> [Dependency] { [] }
    
    public func wrapper_imports(platform: ProjectSpec.Platform) throws -> [WrapperImporter] { [] }
    
    public func will_modify_main_swift() throws -> Bool { false }
    
    public func modify_main_swift(libraries: [String], modules: [String], platform: ProjectSpec.Platform) throws -> [CodeBlock] { [] }
    
    public func plist_entries(plist: inout [String:Any], platform: ProjectSpec.Platform) async throws { }
    
    public func install(support: Path, platform: ProjectSpec.Platform) async throws {}
    
    public func copy_to_site_packages(site_path: Path, platform: ProjectSpec.Platform, py_platform: String) async throws {}
    
    public func will_modify_pyproject() throws -> Bool { false }
    
    public func modify_pyproject(path: Path) async throws {}
    
    public func exclude_dependencies() throws -> [String] { [] }
}
