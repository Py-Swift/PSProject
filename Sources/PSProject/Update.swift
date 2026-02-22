//
//  Update.swift
//  PSProject
//
import ArgumentParser
import PathKit
import TOMLKit
import PyProjectToml
import PSTools
import Backends
import WheelBuilder
import PipRepo
import XcodeProjectBuilder
import ProjectSpec

extension PSProject {
    
    struct Update: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration { .init(
            abstract: abstractInfo,
            subcommands: [
                App.self,
                Simple.self,
                SitePackages.self
            ],
            //defaultSubcommand: SitePackages.self
        )}
        @MainActor
        static func updateSitePackages(uv: Path, reset: Bool) async throws {
            
            func pipInstallReqs(psproject: Tool.PSProject, req_file: Path, root: Path, backends: [any BackendProtocol]) async throws {
                let platforms = try await psproject.getXcodePlatforms(workingDir: root)
                
                let cplatforms = platforms.asChuckedTarget()
                
                for (t, plats) in cplatforms {
                    
                    var extra_index: [String] = []
                    //if let psproject = toml.tool?.psproject {
                        extra_index.append(contentsOf: psproject.extra_index.resolved_path(prefix: uv))
                        switch t {
                            case .iOS:
                                if let ios = psproject.ios {
                                    extra_index.append(contentsOf: ios.extra_index.resolved_path(prefix: uv))
                                }
                            case .macOS:
                                if let macos = psproject.macos {
                                    extra_index.append(contentsOf: macos.extra_index.resolved_path(prefix: uv))
                                }
                            default: fatalError()
                        }
                    //}
                    print("root: \(root) - uv:\(uv)")
                
                    print()
                    for platform in plats {
                        let site_path = platform.getSiteFolder()
                        if reset {
                            try? site_path.delete()
                            try? site_path.mkdir()
                        }
                        if t == .macOS {
                            try await platform.pipInstallDesktop(requirements: req_file, extra_index: extra_index)
                        } else {
                            try await platform.pipInstall(requirements: req_file, extra_index: extra_index)
                        }
                        
                        
                        //
                        for backend in backends {
                            try await backend.copy_to_site_packages(site_path: site_path, platform: platform.xcode_target, py_platform: platform.wheel_platform)
                        }
                        
                    }
                }
            }
            
            let toml_path = (uv.absolute() + "pyproject.toml")
            let toml = try toml_path.loadPyProjectToml()
            
            guard let psproject = toml.tool?.psproject else {
                fatalError("tool.psproject in pyproject.toml not found")
            }
            
            
            
            let workingDir = uv + "project_dist/xcode"
            
            
            let backends = try psproject.loaded_backends()
            
            let req_string = try! await XcodeProjectBuilder.generateReqFromUV(toml: toml, uv: uv, backends: backends)
            let req_file = workingDir + "requirements.txt"
            try req_file.write(req_string)
            
            try await pipInstallReqs(
                psproject: psproject,
                req_file: req_file,
                root: workingDir,
                backends: backends
            )
            
            for (extra_name, extra_target) in psproject.extra_targets {
                let extra_backends = try extra_target.loaded_backends()
                let extra_req_string = try! await XcodeProjectBuilder.generateReqFromUV(toml: toml, uv: uv, backends: extra_backends)
                let extra_root = workingDir + extra_name
                let extra_req_file = extra_root + "requirements.txt"
                try extra_req_file.write(extra_req_string)
                
                try await pipInstallReqs(
                    psproject: psproject,
                    req_file: extra_req_file,
                    root: extra_root,
                    backends: extra_backends
                )
            }
            
        }
        
        
        static func cythonizeApp(uv: Path) async throws {
            
            
            let uv_abs = uv.absolute()
            let toml_path = (uv_abs + "pyproject.toml")
            let toml = try toml_path.loadPyProjectToml()
            
            guard let psproject = toml.tool?.psproject else {
                fatalError("tool.psproject in pyproject.toml not found")
            }
            
            guard psproject.cythonized else {
                print("app module is not configured as cythonizable")
                return
            }
            
            let workingDir = uv + "project_dist/xcode"
            guard workingDir.exists else {
                print("no xcode project found, ignoring cythonize")
                return
            }
            let platforms = try await psproject.getXcodePlatforms(workingDir: workingDir).asChuckedTarget()
            
            
            for (t, plats) in platforms {
                for platform in plats {
                    switch t {
                        case .iOS:
                            try ciBuildWheelApp(
                                src: uv,
                                output_dir: uv_abs + "wheels",
                                arch: "\(platform.arch.name)_\(platform.sdk.wheel_name)",
                                platform: "ios"
                            )
                        case .macOS:
                            break
                        default: fatalError()
                    }
                }
            }
        }
        
        static func updateSimple(uv: Path) async throws {
            let uv_abs = uv.absolute()
            let toml_path = (uv_abs + "pyproject.toml")
            let toml = try toml_path.loadPyProjectToml()
            
            guard let _ = toml.tool?.psproject else {
                fatalError("tool.psproject in pyproject.toml not found")
            }
            
            let cache_dir = uv_abs + "wheels"
            if !cache_dir.exists {
                try? cache_dir.mkdir()
            }
            
            let repo = try RepoFolder(root: cache_dir)
            try repo.generate_simple(output: cache_dir)
        }
    }
    
    
    
    
}


extension PSProject.Update {
    
    struct App: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration {
            .init(
                abstract: abstractInfo,
            )
        }
        
        @Argument var uv: Path?
        
        func run() async throws {
            
            print(infoTitle(title: "Cythonize App Module"))
            
            if !Validation.hostPython() { return }
            try Validation.backends()
                        
            try await PSProject.Update.cythonizeApp(uv: uv ?? .current)
        }
    }
    
    struct SitePackages: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration {
            .init(
                abstract: abstractInfo,
            )
        }
        
        @Argument var uv: Path?
        
        @Flag var reset = false
        
        func run() async throws {
            
            print(infoTitle(title: "Updating Site-Packages"))
            
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            
            try await PSProject.Update.updateSitePackages(
                uv: uv ?? .current,
                reset: reset
            )
        }
    }
    
    struct Simple: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration {
            .init(
                abstract: abstractInfo,
            )
        }
        
        @Argument var uv: Path?
        
        func run() async throws {
            
            print(infoTitle(title: "Updating Wheels Simple"))
            
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            
            
            try await PSProject.Update.updateSimple(uv: uv ?? .current)
            
        }
    }
}


    fileprivate func infoTitle(title: String) -> String {
        var lines = [String]()
        let title_size = title.count
        
        let top_bot = String([Character](repeating: "#", count: title_size + 12))
        lines.append("")
        lines.append(top_bot)
        
        lines.append("##    \(title)    ##")
        lines.append(top_bot)
        lines.append("")
        return lines.joined(separator: "\n")
    }
    
    
   


extension Tool.PSProject {
    func getXcodePlatforms(workingDir: Path) async throws -> [any ContextProtocol] {
        
        var plats: [any ContextProtocol] = []
        //guard let psproject = tool?.psproject else { return plats }
        if let _ = ios {
            plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneOS(), root: workingDir))
            switch arch_info {
                case .intel64:
                    plats.append(try PlatformContext(arch: Archs.X86_64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                case .arm64:
                    plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                default: break
            }
        }
        
        if let _ = macos  {
            switch arch_info {
                case .intel64:
                    plats.append(try PlatformContext(arch: Archs.X86_64(), sdk: SDKS.MacOS(), root: workingDir))
                case .arm64:
                    plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.MacOS(), root: workingDir))
                default: break
            }
        }
        
        
        return plats
        
    }
}


extension [String] {
    func resolved_path(prefix: Path) -> Self {
        map { element in
            element.resolve_path(prefix: prefix, file_url: true)
        }
    }
}
