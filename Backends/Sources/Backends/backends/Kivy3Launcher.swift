//
//  Kivy3Launcher.swift
//  Backends
//
//import PSTools
import PathKit
import ProjectSpec

fileprivate func pre_main_swift(modules: String) -> String {
    """
    KivyLauncher.pyswiftImports = [
        \(modules)
    ]
    """
}

fileprivate let main_swift = """
let exit_status = KivyLauncher.SDLmain()
"""

fileprivate let on_exit = """
exit(exit_status)
"""

fileprivate let new_mode = false

public final class Kivy3Launcher: SDL3Backend {
    
    public override var name: String { "Kivy3Launcher" }
    
    public override init() {
        super.init()
    }
    
    
    public override func exclude_dependencies() throws -> [String] {
        if new_mode {
            []
        } else {
            ["kivy.2", "kivy.3", "kivy==", "kivy>=", "kivy>"]
        }
    }
    
    public override func packages() async throws -> [String : SwiftPackage] {
        [
            "KivyLauncher": .remote(
                url: "https://github.com/kivy-school/KivyLauncher",
                versionRequirement: .branch("master")
            ),
            "Kivy_iOS_Module": .remote(
                url: "https://github.com/kivy-school/Kivy_iOS_Module",
                versionRequirement: .branch("master")
            )
        ]
    }
    
    public override func target_dependencies(platform: Platform) async throws -> [Dependency] {
        var deps = try await super.target_dependencies(platform: platform)
        
        deps.append(
            .init(
                type: .package(products: ["Kivy3Launcher"]),
                reference: "KivyLauncher"
            )
        )
        
        deps.append(
            .init(
                type: .package(products: ["Kivy_iOS_Module"]),
                reference: "Kivy_iOS_Module",
                platformFilter: .iOS
            )
        )
        
        return deps
    }
    
    public override func wrapper_imports(platform: Platform) throws -> [WrapperImporter] {
        switch platform {
            case .iOS: [
                .init(
                    libraries: [.init(name: "Kivy3Launcher"), .init(name: "Kivy_iOS_Module")],
                    modules: [.static_import(".ios")]
                )
            ]
            default: [
                .init(
                    libraries: [.init(name: "Kivy3Launcher")],
                    modules: []
                )
            ]
        }
    }
    
    public override func will_modify_main_swift() throws -> Bool {
        true
    }
    
    public override func modify_main_swift(libraries: [String], modules: [String], platform: Platform) throws -> [CodeBlock] {
        [
            .init(code: pre_main_swift(modules: modules.joined(separator: "\n\t")), priority: .post_imports),
            .init(code: main_swift, priority: .main),
            .init(code: on_exit, priority: .on_exit)
        ]
    }
    
    public override func copy_to_site_packages(site_path: Path, platform: Platform, py_platform: String) async throws {
        
//        switch platform {
//            case .iOS:
//                try await self.pip_install(
//                    "kivy>=3.0.0.dev0",
//                    "--upgrade",
//                    "--disable-pip-version-check",
//                    "--platform=\(py_platform)",
//                    "--only-binary=:all:",
//                    "--extra-index-url", self.pyswift_simple,
//                    "--extra-index-url", self.beeware_simple,
//                    "--extra-index-url", self.kivyschool_simple,
//                    "--python-version=313",
//                    "--target", site_path.string
//                )
//            case .macOS:
//                try await self.pip_install(
//                    "kivy>=2.3.1",
//                    "--upgrade",
//                    "--disable-pip-version-check",
//                    "--only-binary=:all:",
//                    "--python-version=313",
//                    "--target", site_path.string
//                )
//            default:
//                fatalError("\(platform) not implemented")
//        }
    }
    
    public override func install(support: Path, platform: Platform) async throws {
        //if platform == .iOS {
        
        
        
        let sdl_frameworks: Path = support + "sdl3_frameworks"
        if !sdl_frameworks.exists {
            try await self.pip_install(
                "kivy_sdl3_angle",
                "--extra-index-url", self.kivyschool_simple,
                "-t", sdl_frameworks.string
            )
        }
        //}
        
    }
    
    public func do_install(support: Path, platform: ProjectSpec.Platform) async throws {
        try await install(support: .ps_support, platform: platform)
        
        for fw in try await frameworks() {
            let path = fw
            let target = support + path.lastComponent
            print(fw, target)
            if target.exists { continue }
            try path.copy(target)
        }
    }
}



