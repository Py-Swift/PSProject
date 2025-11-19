//
//  Target.swift
//  PSProject
//
import XcodeGenKit
@preconcurrency import ProjectSpec
@preconcurrency import Yams
@preconcurrency import PathKit
import PyProjectToml
import TOMLKit
import Foundation

extension XcodeProjectBuilder {
    public class ProjectTarget {
        
        public let name: String
        public let py_app: Path
        public let platforms: [ProjectSpec.Platform]
        
        let toml: PyProjectToml
        let toml_table: TOMLTable
        let workingDir: Path
        let extra_target: Tool.PSProject.ExtraTarget?
        
        var is_extra: Bool { extra_target != nil }
        
        init(name: String, py_app: Path, platforms: [ProjectSpec.Platform], toml: PyProjectToml, toml_table: TOMLTable, workingDir: Path, extra_target: Tool.PSProject.ExtraTarget? = nil) {
            self.name = name
            self.py_app = py_app
            self.platforms = platforms
            self.toml = toml
            self.toml_table = toml_table
            self.workingDir = workingDir
            self.extra_target = extra_target
        }
        
        static func extraTarget(name: String, py_app: Path, platforms: [ProjectSpec.Platform], toml: PyProjectToml, toml_table: TOMLTable, workingDir: Path, extra_target: Tool.PSProject.ExtraTarget) -> ProjectTarget {
            let new = ProjectTarget(
                name: name,
                py_app: py_app,
                platforms: platforms,
                toml: toml,
                toml_table: toml_table,
                workingDir: workingDir + name,
                extra_target: extra_target
            )
            
            
            
            return new
        }
    }
}

fileprivate extension XcodeProjectBuilder.ProjectTarget {
    
    func settings() async throws -> Settings {
        let configDict: [String: Any] = [
            "LIBRARY_SEARCH_PATHS": [
                "$(inherited)",
            ],
            "SWIFT_VERSION": "5.0",
            "ENABLE_BITCODE": false,
            //"PRODUCT_NAME": "$(PROJECT_NAME)"
        ]
        //        if let projectSpec = project?.projectSpecData {
        //            try loadBuildConfigKeys(from: projectSpec, keys: &configDict)
        //        }
        
        var configSettings: Settings {
            .init(dictionary: configDict)
        }
        
        return .init(configSettings: [
            "Debug": configSettings,
            "Release": configSettings
        ])
    }
    
    func configFiles() async throws -> [String : String] {
        [:]
    }
    
    func sources() async throws -> [ProjectSpec.TargetSource] {
        let current = workingDir
        
        
        
        var sourcesPath: Path {
            
            return (current + "Sources")
        }
        
        var sourcesPaths: [ProjectSpec.TargetSource] = platforms.compactMap { target_type in
            let group = if let extra_target {
                "\(extra_target.name)/Sources"
            } else {
                "Sources"
            }
            switch target_type {
                case .iOS:
                    let target_src = sourcesPath + "IphoneOS"
                    return .init(path: (target_src).string, group: group, type: .group, destinationFilters: [.iOS])
                case .macOS:
                    let target_src = sourcesPath + "MacOS"
                    return .init(path: (target_src).string, group: group, type: .group, destinationFilters: [.macOS])
                default:
                    return nil
            }
        }
        if extra_target == nil {
            sourcesPaths.append(.init(path: (sourcesPath + "Shared").string, group: "Sources", type: .group))
        }
        
        
        let target_group = workingDir.lastComponent
        //let res_group = single_target ? "Resources" : "\(target_group)/Resources"
        let res_group = "Resources"
        let support_group = (workingDir + "Support")
        let dylib_plist = if is_extra {
            workingDir + "dylib-Info-template.plist"
        } else {
            support_group + "dylib-Info-template.plist"
        }
        
        var sources: [ProjectSpec.TargetSource] = [
            .init(path: "\(res_group)/Images.xcassets", group: res_group),
            //.init(path: "\(res_group)/icon.png", group: res_group),
            //.init(path: (sourcesPath).string, group: target_group, type: .group),
        ] + sourcesPaths
        
        sources.append(.init(path: (sourcesPath).string, group: target_group, type: .group))
        
        sources.append(.init(
            path: "\(res_group)/Launch Screen.storyboard",
            group: res_group,
            destinationFilters: [.iOS]
        ))
        sources.append(.init(path: dylib_plist.string, group: "Support"))
                
        return sources
    }
    
    func dependencies() async throws -> [ProjectSpec.Dependency] {
        
        var output: [ProjectSpec.Dependency] = [
            
            .init(type: .package(products: ["PySwiftKitBase"]), reference: "PySwiftKit"),
            .init(type: .package(products: ["CPython"]), reference: "CPython"),
            
        ]
        if let tool = toml.tool, let project = tool.psproject{
            
            if let extra_target {
                for backend in try extra_target.loaded_backends() {
                    for platform in self.platforms {
                        let fws: [ProjectSpec.Dependency] = try await backend.target_dependencies(platform: platform)
                        output.append(contentsOf: fws)
                    }
                }
            } else {
                let backends = try project.loaded_backends()
                for backend in backends {
                    for platform in self.platforms {
                        let fws: [ProjectSpec.Dependency] = try await backend.target_dependencies(platform: platform)
                        output.append(contentsOf: fws)
                    }
                }
            }
            
        }
        
        
        return output
    }
    
    func loadBasePlistKeys(from text: String,  keys: inout [String:Any]) throws {
        
        guard let spec = try Yams.load(yaml: text) as? [String: Any] else { return }
        keys.merge(spec)
    }
    
    func info() async throws -> ProjectSpec.Plist {
        var mainkeys: [String:Any] = [:]
        
        try loadBasePlistKeys(from: project_plist_keys, keys: &mainkeys)
        
        for platform in self.platforms {
            for backend in try toml.backends() {
                try await backend.plist_entries(plist: &mainkeys, platform: platform)
            }
        }
        
        if
            let pyswift = toml_table["pyswift"] ,
            let project = pyswift["project"],
            let plist = project["plist"]?.table,
            let plist_data = plist.convert(to: .json).data(using: .utf8),
            let json = try JSONSerialization.jsonObject(with: plist_data) as? [String:Any]
        {
            mainkeys.merge(json)
        }
        
        
        return .init(path: "Sources/Info.plist", attributes: mainkeys)
    }
    
    func entitlements() async throws -> ProjectSpec.Plist? {
        nil
    }
    
    func attributes() async throws -> [String : Any] {
        [:]
    }
}

extension XcodeProjectBuilder.ProjectTarget {
    func export() async throws -> Target {
        .init(
            name: name,
            type: .application,
            platform: .auto,
            supportedDestinations: [.iOS, .macOS],
            productName: nil,
            deploymentTarget: nil,
            settings: try await settings(),
            configFiles: try await configFiles(),
            sources: try await sources(),
            dependencies: try await dependencies(),
            info: try await info(),
            entitlements: try await entitlements(),
            transitivelyLinkDependencies: false,
            directlyEmbedCarthageDependencies: false,
            requiresObjCLinking: true,
            preBuildScripts: try await preBuildScripts(),
            buildToolPlugins: try await buildToolPlugins(),
            postCompileScripts: try await postCompileScripts(),
            postBuildScripts: try await postBuildScripts(),
            buildRules: [],
            scheme: nil,
            legacy: nil,
            attributes: try await attributes(),
            onlyCopyFilesOnInstall: false,
            putResourcesBeforeSourcesBuildPhase: false
        )
    }
}
