//
//  HostPython.swift
//  PSProject
//
import Foundation
import ArgumentParser
import PathKit
import PSTools

extension PSProject {
    struct HostPython: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration {
            .init(subcommands: [
                Install.self,
                SetPath.self
            ])
        }
        
        struct Install: AsyncParsableCommand {
            
            func run() async throws {
                
                //let _app_sup = Path(URL.applicationSupportDirectory.path(percentEncoded: false))
                let app_dir = PathKit.Path.ps_shared
                print(app_dir)
                if !app_dir.exists { try! app_dir.mkpath() }
                
                try await buildHostPython(version: HOST_PYTHON_VER, path: app_dir)
                InstallPythonCert(python: (app_dir + "hostpython3/bin/python3").url)
            }
        }
        
        struct SetPath: AsyncParsableCommand {
            
            @Argument var python: Path
            
            func run() async throws {
                let current = Path.current
                let xcode = current + "project_dist/xcode"
                var python = python
                
                if python.isFile {
                    let parent = python.parent()
                    if parent.lastComponent == "bin" {
                        python = parent.parent()
                    }
                } 
                
                let hostpython: Path = .ps_shared + "hostpython3"
                //for path in [Path.p] {
                if hostpython.exists { try? hostpython.delete() }
                try? python.link(hostpython)
                //}
                
                
            }
        }
    }
}
