//
//  Extensions.swift
//  PSProject
//
import PyProjectToml
import Backends
import PathKit


@MainActor
fileprivate var loadedBackends: [any BackendProtocol] = []


extension PyProjectToml {
    @MainActor
    public func backends() throws -> [any BackendProtocol] {
        if backendsIsLoaded { return loadedBackends }
        
        if let psproject = tool?.psproject {
            try psproject.loaded_backends()
        }
        backendsIsLoaded.toggle()
        return loadedBackends
    }
}

extension Tool.PSProject {
    
    
    //private var _loaded_backends: [any BackendProtocol] = []
    
    @MainActor
    public func loaded_backends() throws -> [any BackendProtocol] {
        print(Self.self, "loaded_backends")
        if loadedBackends.isEmpty {
            loadedBackends = try self.get_backends()
        }
        return loadedBackends
    }
    @MainActor
    private func get_backends()  throws ->  [any BackendProtocol] {
        let backends_root = Path.ps_shared + "backends"
        let backends = backends ?? []
        
        return (backends).compactMap { b in
            switch Tool.PSProject.PSBackend(rawValue: b) {
                case .kivylauncher: KivyLauncher()
                case .kivy3launcher: Kivy3Launcher()
                case .pyswiftui: PySwiftUI()
                case .none: fatalError()
            }
        }
        
    }
}
