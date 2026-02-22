//
//  ExtraTarget.swift
//  PyProjectToml
//
//  Created by CodeBuilder on 18/11/2025.
//
import Backends
import PathKit
import JSONUtilities

extension Tool.PSProject {
    public final class ExtraTarget: Decodable {
        public var name: String?
        public let type: TargetType
        public let sources: [Path]?
        public let explicit_site: Bool
        public let backends: [String]
        public let extra_dependencies: [String]
        
        enum CodingKeys: CodingKey {
            case name
            case target_type
            case type
            case explicit_site
            case backends
            case extra_dependencies
            case sources
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Tool.PSProject.ExtraTarget.CodingKeys> = try decoder.container(keyedBy: Tool.PSProject.ExtraTarget.CodingKeys.self)
            //self.name = try container.decode(String.self, forKey: Tool.PSProject.ExtraTarget.CodingKeys.name)
            self.explicit_site = try container.decodeIfPresent(Bool.self, forKey: Tool.PSProject.ExtraTarget.CodingKeys.explicit_site) ?? false
            self.backends = try container.decodeIfPresent([String].self, forKey: Tool.PSProject.ExtraTarget.CodingKeys.backends) ?? []
            self.extra_dependencies = try container.decodeIfPresent([String].self, forKey: Tool.PSProject.ExtraTarget.CodingKeys.extra_dependencies) ?? []
            self.type = try container.decodeIfPresent(TargetType.self, forKey: .type) ?? .app
            self.sources = try container.decodeIfPresent([String].self, forKey: .sources)?.map({.init($0)})
        }
        
        
        private var _loaded_backends: [any BackendProtocol] = []
        
        @MainActor
        public func loaded_backends() throws -> [any BackendProtocol] {
            print(Self.self, "loaded_backends")
            if _loaded_backends.isEmpty {
                self._loaded_backends = try self.get_backends()
            }
            return _loaded_backends
        }
        @MainActor
        private func get_backends()  throws ->  [any BackendProtocol] {
            let backends_root = Path.ps_shared + "backends"
            let backends = backends ?? []
            
            return try (backends).compactMap { b in
                switch PSBackend(rawValue: b) {
                    case .kivylauncher: KivyLauncher()
                    case .kivy3launcher: Kivy3Launcher()
                    case .pyswiftui: PySwiftUI()
                    case .none: fatalError()
                }
            }
            
        }
        
       
    }
}

extension Tool.PSProject.ExtraTarget {
    public enum TargetType: String, Codable {
        case app
        case app_extension
    }
}
