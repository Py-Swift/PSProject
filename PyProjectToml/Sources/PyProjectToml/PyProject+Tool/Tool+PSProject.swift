//
//  Tool+PSProject.swift
//  PSProjectGenerator
//
//import PSBackend
import PathKit
//import Backends
//import PySwiftKit

extension Path {
    static var ps_shared: Path { "/Users/Shared/psproject"}
    static var ps_support: Path { ps_shared + "support" }
    
}

extension Tool {
    
    //@MainActor
    public final class PSProject: Decodable {
        public let app_name: String?
        public let swift_main: String?
        public let swift_sources: [String]?
        //public let pip_install_app: Bool?
        public let copy__main__py: Bool
        public let backends: [String]?
        //public let dependencies: Dependencies?
        
        public let exclude_dependencies: [String]?
        
        public let wheel_cache_dir: String?
        public let extra_index: [String]
        
        public let cythonized: Bool
        // platforms
        public var android: Platforms.Android?
        public var ios: Platforms.iOS?
        public var macos: Platforms.macOS?
        
        public var swift_packages: [String: SwiftPackage]
        
        public var extra_targets: [String:ExtraTarget]
        
        private enum CodingKeys: CodingKey {
            case app_name
            case swift_main
            case swift_sources
            case swift_packages
            case pip_install_app
            case copy_main_py
            case backends
            //case dependencies
            case platforms
            case exclude_dependencies
            case extra_index
            case wheel_cache_dir
            
            case cythonized
            
            case android
            case ios
            case macos
            
            case extra_targets
        }
        
        nonisolated public init(from decoder: any Decoder) throws {
            
            
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.app_name = try container.decodeIfPresent(String.self, forKey: .app_name)
            self.swift_main = try container.decodeIfPresent(String.self, forKey: .swift_main)
            self.swift_sources = try container.decodeIfPresent([String].self, forKey: .swift_sources)
            //self.pip_install_app = try container.decodeIfPresent(Bool.self, forKey: .pip_install_app)
            self.copy__main__py = try container.decodeIfPresent(Bool.self, forKey: .copy_main_py) ?? true
            self.backends = try container.decodeIfPresent([String].self, forKey: .backends)
            //self.dependencies = try container.decodeIfPresent(Dependencies.self, forKey: .dependencies)
            
            self.exclude_dependencies = try container.decodeIfPresent([String].self, forKey: .exclude_dependencies)
            self.extra_index = try container.decodeIfPresent([String].self, forKey: .extra_index) ?? [
                "https://pypi.anaconda.org/beeware/simple",
                "https://pypi.anaconda.org/pyswift/simple",
                "https://pypi.anaconda.org/kivyschool/simple"
            ]
            self.wheel_cache_dir = try container.decodeIfPresent(String.self, forKey: .wheel_cache_dir)
            
            self.cythonized = try container.decodeIfPresent(Bool.self, forKey: .cythonized) ?? false
            
            self.swift_packages = try container.decodeIfPresent([String:SwiftPackage].self, forKey: .swift_packages) ?? [:]
            
            self.android = try container.decodeIfPresent(Platforms.Android.self, forKey: .android)
            self.ios = try container.decodeIfPresent(Platforms.iOS.self, forKey: .ios)
            self.macos = try container.decodeIfPresent(Platforms.macOS.self, forKey: .macos)
            self.extra_targets = try container.decodeIfPresent([String:ExtraTarget].self, forKey: .extra_targets) ?? [:]
            
            for (k,v) in extra_targets {
                v.name = k
            }
        }
        
//        private var _loaded_backends: [any BackendProtocol] = []
//        
//        @MainActor
//        public func loaded_backends() throws -> [any BackendProtocol] {
//            print(Self.self, "loaded_backends")
//            if _loaded_backends.isEmpty {
//                self._loaded_backends = try self.get_backends()
//            }
//            return _loaded_backends
//        }
//        @MainActor
//        private func get_backends()  throws ->  [any BackendProtocol] {
//            let backends_root = Path.ps_shared + "backends"
//            var backends = backends ?? []
//            
//            
//            print("get_backends: \(backends)")
//            return try (backends).compactMap { b in
//                switch PSBackend(rawValue: b) {
//                    case .kivylauncher: KivyLauncher()
//                    case .kivy3launcher: Kivy3Launcher()
//                    case .pyswiftui: PySwiftUI()
//                    case .none: fatalError()
//                }
//            }
//            
//        }
//        
    }
    
    
}

//public typealias Tool_PSProject = PyProjectToml.Tool.PSProject

extension Tool.PSProject {
    public struct Dependencies: Decodable, Sendable {
        public let pips: [String]?
        
        
        enum CodingKeys: CodingKey {
            case pips
        }
        
        public nonisolated init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.pips = try container.decodeIfPresent([String].self, forKey: .pips)
        }
    }
    
    public enum PSBackend: String {
        case kivylauncher = "kivyschool.kivylauncher"
        case kivy3launcher = "kivyschool.kivy3launcher"
        case pyswiftui
    }
}


//extension Tool.PSProject {
//    public func contextPlatforms(workingDir: Path) throws -> [any ContextProtocol] {
//        var plats: [any ContextProtocol] = []
//        
//        if let ios {
//            plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneOS(), root: workingDir))
//            switch arch_info {
//                case .intel64:
//                    plats.append(try PlatformContext(arch: Archs.X86_64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
//                case .arm64:
//                    plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
//                default: break
//            }
//        }
//        
//        if let macos {
//            
//        }
//        
//        return plats
//    }
//    
//    
//}
