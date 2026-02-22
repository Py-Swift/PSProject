
import Foundation
import PathKit
import ProjectSpec
//import PSTools

public class PyFrameworkBackend: BackendProtocol {
    
    
    
    public var name: String { "PyFrameworkBackend"}
    
    let version = "3.13"
    let sub_version = "b11"

    public var app_name: String?
    
    
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
}





