//
//  AppExtensionTarget.swift
//  PSProject
//
import XcodeGenKit
@preconcurrency import ProjectSpec
@preconcurrency import Yams
@preconcurrency import PathKit
import PyProjectToml
import TOMLKit
import Foundation
import Backends



extension XcodeProjectBuilder {
    public class AppExtensionTarget {
        
        public let name: String
        public let py_app: Path
        public let platforms: [ProjectSpec.Platform]
        
        let toml: PyProjectToml
        let toml_table: TOMLTable
        let workingDir: Path
        let info: Tool.PSProject.ExtraTarget
        
        
        init(name: String, py_app: Path, platforms: [ProjectSpec.Platform], toml: PyProjectToml, toml_table: TOMLTable, workingDir: Path, extra_target: Tool.PSProject.ExtraTarget) {
            self.name = name
            self.py_app = py_app
            self.platforms = [.iOS]
            self.toml = toml
            self.toml_table = toml_table
            self.workingDir = workingDir + name
            self.info = extra_target
        }
        
        private func toml_data() -> TOMLTable? {
            guard
                let info_name = info.name,
                let pyswift = toml_table["tool"] ,
                let project = pyswift["psproject"],
                let ext_target = project["extra_targets"]?[info_name]
            else {
                return nil
            }
            return ext_target.table
        }
    }
    
    
}

fileprivate extension XcodeProjectBuilder.AppExtensionTarget {
    
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
    
    private func sources() async throws -> [ProjectSpec.TargetSource] {
        if
            let ext_sources = toml_data()?["sources"]?.array
        {
            return ext_sources.compactMap(\.string).map { ext_src in
                .init(path: Path(ext_src).absolute().string, group: info.name)
            }
            
        }
        return []
    }
    
    
    
    
    @MainActor
    func dependencies() async throws -> [ProjectSpec.Dependency] {
        
        var output: [ProjectSpec.Dependency] = [
            
            .init(type: .package(products: ["PySwiftKitBase"]), reference: "PySwiftKit"),
//            .init(type: .package(products: ["CPython"]), reference: "CPython"),
            
        ]
        if
            let dependencies = toml_data()?["dependencies"]?.array
        {
            for dep in dependencies {
                guard let package = dep["package"]?.table, let products = package["products"]?.array, let ref = package["reference"]?.string else { continue }
                //fatalError(ref)
                output.append(.init(type: .package(products: products.compactMap(\.string)), reference: ref))
            }
            
        }
        
        return output
    }
    
    func loadBasePlistKeys(from text: String,  keys: inout [String:Any]) throws {
        
        guard let spec = try Yams.load(yaml: text) as? [String: Any] else { return }
        keys.merge(spec)
    }
    
    @MainActor
    func info() async throws -> ProjectSpec.Plist {
        var mainkeys: [String:Any] = [:]
        
            let extra_name = info.name
            if
                let plist = toml_data()?["info_plist"]?.table,
                let plist_data = plist.convert(to: .json).data(using: .utf8),
                let json = try JSONSerialization.jsonObject(with: plist_data) as? [String:Any]
            {
                print("tool.psproject.extra_targets", json)
                mainkeys.merge(json)
                
            }
            
       
        
        
        return .init(path: "\(extra_name)/Info.plist", attributes: mainkeys)
    }
    
    func entitlements() async throws -> ProjectSpec.Plist? {
        let extra_name = info.name
        if
            let plist = toml_data()?["entitlements"]?.table,
            //let plist = ext_target["entitlements"]?.table,
            let plist_data = plist.convert(to: .json).data(using: .utf8),
            let json = try JSONSerialization.jsonObject(with: plist_data) as? [String:Any]
        {
            print("tool.psproject.entitlements", json)
            return .init(path: "\(self.name).entitlements", attributes: json)
        }
        return nil
    }
    
    func attributes() async throws -> [String : Any] {
        [:]
    }
}

extension XcodeProjectBuilder.AppExtensionTarget {
    func export() async throws -> Target {
        .init(
            name: name,
            type: .appExtension,
            platform: .iOS,
            supportedDestinations: [.iOS],
            productName: toml.tool?.psproject?.app_name,
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
            preBuildScripts: [],
//            buildToolPlugins: try await buildToolPlugins(),
//            postCompileScripts: try await postCompileScripts(),
//            postBuildScripts: try await postBuildScripts(),
            buildRules: [],
            scheme: nil,
            legacy: nil,
            attributes: try await attributes(),
            onlyCopyFilesOnInstall: false,
            putResourcesBeforeSourcesBuildPhase: false
        )
    }
}


