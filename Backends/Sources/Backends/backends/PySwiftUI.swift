//
//  PySwiftUI.swift
//  Backends
//
//  Created by CodeBuilder on 15/12/2025.
//

import Foundation
import PathKit
import ProjectSpec
//import PSTools

public class PySwiftUI: BackendProtocol {
    public var name: String = "PySwiftUI"
    
    public var app_name: String?
    
    public init() {
        
    }
    
    public func packages() async throws -> [String : SwiftPackage] {
        [
            "SwiftUI_PyEngine": .local(path: "/Volumes/CodeSSD/GitHub/SwiftUI_PyEngine", group: nil, excludeFromProject: false)
        ]
    }
    
    public func target_dependencies(platform: Platform) async throws -> [Dependency] {
        [
            .init(type: .package(products: ["SwiftUI_PyEngine"]), reference: "SwiftUI_PyEngine")
        ]
    }
    
    public func will_modify_main_swift() throws -> Bool {
        true
    }
    
    public func main_swift_name() throws -> String? {
        guard let app_name else { return "App"}
        return "\(app_name)App"
    }
    
    public func modify_main_swift(libraries: [String], modules: [String], platform: Platform) throws -> [CodeBlock] {
        [
            imports_code(),
            pre_main_code(platform: platform),
            main_code()
        ]
    }
    
    func imports_code() -> CodeBlock {
        .init(
            code: """
            import SwiftUI
            """,
            priority: .imports
        )
    }
    
    func pre_main_code(platform: Platform) -> CodeBlock {
        switch platform {
            case .auto, .macOS:
                .init(
                    code: """
                    
                    """,
                    priority: .pre_main
                )
            case .iOS, .tvOS, .watchOS, .visionOS:
                .init(
                    code: """
                    
                    """,
                    priority: .pre_main
                )
        }
    }
    
    func main_code() -> CodeBlock {
        .init(
            code: """
            @main
            struct \(app_name ?? "SwiftUI")App: App {
                var body: some Scene {
                    WindowGroup {
                        Text("PySwiftUI")
                    }
                }
            }
            """,
            priority: .main
        )
    }
    
    
}
