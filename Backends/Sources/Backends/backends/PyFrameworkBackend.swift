
import Foundation
import PathKit
import ProjectSpec
//import PSTools

public class PyFrameworkBackend: BackendProtocol {
    
    public var name: String { "PyFrameworkBackend"}
    
    public let version = "3.13"
    let sub_version = "b11"
    let android_version = "3.13.8"

    public var app_name: String?
    
    public init() {}
    
    // MARK: - ABI → NDK triple (only x86_64 and arm64-v8a)
    
    public static func androidTriple(for abi: String) -> String {
        switch abi {
        case "arm64-v8a": return "aarch64-linux-android"
        case "x86_64": return "x86_64-linux-android"
        default: fatalError("Unsupported ABI: \(abi). Only arm64-v8a and x86_64 are supported.")
        }
    }
    
    // MARK: - Apple (download)
    
    fileprivate func download(version: String, sub_version: String , platform: String, destination: Path ) async throws -> Path {
        let url: URL = .init(string: "https://github.com/beeware/Python-Apple-support/releases/download/\(version)-\(sub_version)/Python-\(version)-\(platform)-support.\(sub_version).tar.gz")!
        let (tmp, _) = try await URLSession.download(from: url)
        let filename = "Python-\(version)-\(platform)-support.{\(sub_version).tar.gz"
        let py_fw_tar = destination + filename
        try tmp.move(py_fw_tar)
        return py_fw_tar
    }
    @MainActor
    public func install(support: Path, platform: Platform) async throws {
        
        
        
        let _support = Path.ps_support
        let py_fw  = _support + "Python.xcframework"
        
        print(#file, #line, py_fw)
        
        
        
        switch platform {
                
            case .iOS:
                if py_fw.exists { return }
                let py_fw_tar = try await download(
                    version: version,
                    sub_version: sub_version,
                    platform: platform.rawValue,
                    destination: _support
                )
                try _support.chdir {
                    
                    try Process.untar(url: py_fw_tar)
                    try py_fw_tar.delete()
                }
            case .macOS:
                let py_fw_tar = try await download(
                    version: version,
                    sub_version: sub_version,
                    platform: platform.rawValue,
                    destination: _support
                )
                try _support.chdir {
                    try Process.untar(url: py_fw_tar)
                    try py_fw_tar.delete()
                }
                let python_lib = _support + "Python.xcframework/macos-arm64_x86_64/Python.framework/Versions/3.13/lib"
                
                let files_to_remove: [Path] = [
                    python_lib + "libpython3.13.dylib",
                    python_lib + "python3.13/config-3.13-darwin"
                ]
                
                for file in files_to_remove {
                    if file.exists {
                        try? file.delete()
                    }
                }
                
                
                
            case .auto:
                break
                
            case .tvOS, .watchOS, .visionOS:
                break
        }
    }
    
    // MARK: - Android (build from source)
    
    @MainActor
    public func installAndroid(workingDir: Path, archs: [String], sdk: String?, ndk: String?) async throws {
        let psprojectDir = workingDir + ".psproject"
        let cpythonDir = psprojectDir + "Python-\(android_version)"
        
        // Download CPython source if not present
        if !cpythonDir.exists {
            try psprojectDir.mkpath()
            print("Downloading CPython \(android_version) source...")
            let url: URL = .init(string: "https://www.python.org/ftp/python/\(android_version)/Python-\(android_version).tgz")!
            let (tmp, _) = try await URLSession.download(from: url)
            let tarPath = psprojectDir + "Python-\(android_version).tgz"
            try tmp.move(tarPath)
            try psprojectDir.chdir {
                try Process.untar(url: tarPath)
                try tarPath.delete()
            }
        }
        
        var env = ProcessInfo.processInfo.environment
        if let sdk { env["ANDROID_HOME"] = sdk }
        if let ndk { env["ANDROID_NDK_ROOT"] = ndk }
        
        for arch in archs {
            let triple = Self.androidTriple(for: arch)
            let prefix = cpythonDir + "cross-build/\(triple)/prefix"
            
            if (prefix + "lib/libpython\(version).so").exists {
                print("CPython \(version) for \(arch) already built")
                continue
            }
            
            print("Building CPython \(android_version) for \(arch) (\(triple))...")
            
            let configure = Process()
            configure.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            configure.arguments = ["python3", "Android/android.py", "configure-host", triple]
            configure.currentDirectoryURL = URL(fileURLWithPath: cpythonDir.string)
            configure.environment = env
            try configure.run()
            configure.waitUntilExit()
            guard configure.terminationStatus == 0 else {
                fatalError("configure-host failed for \(triple)")
            }
            
            let make = Process()
            make.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            make.arguments = ["python3", "Android/android.py", "make-host", triple]
            make.currentDirectoryURL = URL(fileURLWithPath: cpythonDir.string)
            make.environment = env
            try make.run()
            make.waitUntilExit()
            guard make.terminationStatus == 0 else {
                fatalError("make-host failed for \(triple)")
            }
            
            print("CPython \(version) for \(arch) built successfully")
        }
    }
    
    public func androidPrefix(workingDir: Path, arch: String) -> Path {
        let triple = Self.androidTriple(for: arch)
        return workingDir + ".psproject/Python-\(android_version)/cross-build/\(triple)/prefix"
    }
}





