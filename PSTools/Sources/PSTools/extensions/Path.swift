//
//  Path.swift
//  PythonSwiftProject
//
@preconcurrency import PathKit
import Foundation
//import Subprocess

extension Path: @unchecked Swift.Sendable {}

//extension Executable {
//    public static var python3: Self { .path(.init(Path.python3.string)) }
//    public static var pip3: Self { .path(.init(Path.python3.string)) }
//}

extension Path {
    public static var ps_shared: Self { "/Users/shared/psproject" }
    public static var ps_support: Self { ps_shared + "Support" }
    
    
    public static var host_python: Self { ps_shared + "hostpython3"}
    fileprivate static var host_python_bin: Self { ps_shared + "bin" }
    public static var python3: Self { host_python_bin + "python3" }
    public static var pip3: Self { host_python_bin + "pip3" }
    
    public static let cibuildwheel = which.cibuildwheel
}

public func getHostPython() -> Path {
    let env = ProcessInfo.processInfo.environment
    
    if let host_python = env["HOST_PYTHON"] {
        let path: Path = .init(host_python)
        if path.isFile {
            let parent = path.parent()
            if parent.lastComponent == "bin" {
                return parent.parent()
            }
        }
        return .init(host_python)
    }
    
    let local_path = Path.current + ".hostpython"
    if local_path.exists, let _host_python = try? local_path.read(.utf8) {
        let path = Path(_host_python)
        if path.isFile {
            let parent = path.parent()
            if parent.lastComponent == "bin" {
                return parent.parent()
            }
        }
        return path
    }
    
    return .ps_shared + "hostpython3"
}


public extension Path {
    static let hostPython = getHostPython()//Path.ps_shared + "hostpython3"
    static let venv = Path.hostPython + "venv"
    static let venvActivate = (Path.venv + "bin/activate")
    
    var escapedString: String {
        string.replacingOccurrences(of: " ", with: "\\ ")
    }
    var escapedWithoutExt: String {
        
        lastComponentWithoutExtension.replacingOccurrences(of: " ", with: "\\ ")
    }
}


extension Path {
    //@MainActor
    public func chdir(closure: () async throws -> ()) async rethrows {
        let previous = Path.current
        Path.current = self
        defer { Path.current = previous }
        try await closure()
      }
    
    public static func withTemporaryFolder(_ handle: @escaping (Path) throws ->Void) throws {
        let tmp = try Path.uniqueTemporary()
        try tmp.mkpath()
        defer { try? tmp.delete() }
        try tmp.chdir {
            try handle(tmp)
        }
        
    }
    
    //@MainActor
    public static func withTemporaryFolder(_ handle: @escaping (Path) async throws ->Void) async throws {
        let tmp = try Path.uniqueTemporary()
        try tmp.mkpath()
        defer { try? tmp.delete() }
        try await tmp.chdir {
            try await handle(tmp)
        }
        
    }
}

public extension Path {
    func mkpath(ignore: Bool) throws {
        if ignore, exists {
            return
        }
        try mkpath()
    }
    func mkdir(ignore: Bool) throws {
        if ignore, exists {
            return
        }
        try mkdir()
    }
}
