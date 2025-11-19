//
//  ProjectTarget+Scripts.swift
//  PSProject
//
import XcodeGenKit
@preconcurrency import ProjectSpec

extension XcodeProjectBuilder.ProjectTarget {
    public func preBuildScripts() async throws -> [ProjectSpec.BuildScript] {
        return []
    }
    
    public func buildToolPlugins() async throws -> [ProjectSpec.BuildToolPlugin] {
        [
            //.init(plugin: "Swiftonize", package: "SwiftonizePlugin")
        ]
    }
    
    public func postCompileScripts() async throws -> [ProjectSpec.BuildScript] {
        []
    }
    
    public func postBuildScripts() async throws -> [ProjectSpec.BuildScript] {
        let appModule: ProjectSpec.BuildScript = if let cythonized = toml.tool?.psproject?.cythonized, cythonized {
            .installAppWheelModule(name: toml.project.name, extra_target: extra_target?.name)
        } else {
            .installAppModule(pythonProject: py_app, extra_target: extra_target?.name)
        }
        return [
            appModule,
            .installPyModules(pythonProject: py_app, extra_target: extra_target?.name),
            .signPythonBinary(sub_version: 13)
        ]
    }
}
