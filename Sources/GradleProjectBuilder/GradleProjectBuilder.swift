//
//  GradleProjectBuilder.swift
//  PSProject
//
import PathKit
import PyProjectToml
import Backends

@MainActor
public final class GradleProjectBuilder {
    
    let workingDir: Path
    let pyproject: PyProjectToml
    let android: Tool.PSProject.Platforms.Android?
    let psproject: Tool.PSProject
    let appName: String
    let packageName: String
    let archs: [String]
    
    init(pyproject: PyProjectToml, workingDir: Path, archs: [String]) {
        self.pyproject = pyproject
        self.workingDir = workingDir
        self.archs = archs
        
        let ps = pyproject.tool!.psproject!
        self.psproject = ps
        self.android = ps.android
        self.appName = ps.app_name ?? pyproject.project.name
        self.packageName = android?.package_name ?? "org.pyswift.\(pyproject.project.name)"
    }
    
    @discardableResult
    public static func create(uv: Path, archs: [String]) async throws -> Self {
        let pyproject_toml: Path = uv + "pyproject.toml"
        let pyproject = try pyproject_toml.loadPyProjectToml()
        
        guard pyproject.tool?.psproject != nil else {
            fatalError("[tool.psproject] is missing")
        }
        
        let builder = Self.init(pyproject: pyproject, workingDir: uv, archs: archs)
        try await builder.generate()
        return builder
    }
    
    /// The Android backend names from `[tool.psproject]` or `[tool.psproject.android]`
    var backendNames: [String] {
        android?.backends ?? psproject.backends ?? []
    }
    
    /// Resolves which SDL bootstrap style to use based on configured backends
    var sdlVersion: Int {
        for b in backendNames {
            switch Tool.PSProject.PSBackend(rawValue: b) {
            case .kivy3launcher: return 3
            default: continue
            }
        }
        return 2
    }
    
    func generate() async throws {
        let distDir = workingDir + "project_dist/gradle"
        try distDir.mkpath()
        
        // Root Gradle files
        try GradleBuildFiles.writeRootBuildGradle(to: distDir)
        try GradleBuildFiles.writeSettingsGradle(to: distDir, appName: appName)
        try GradleBuildFiles.writeGradleProperties(to: distDir)
        
        // app module
        let appDir = distDir + "app"
        try appDir.mkpath()
        try GradleBuildFiles.writeAppBuildGradle(
            to: appDir,
            packageName: packageName,
            minSdk: Int(android?.ndk_api ?? "21") ?? 21,
            targetSdk: android?.api?.rawValue ?? 35,
            archs: archs
        )
        
        // AndroidManifest
        let manifestDir = appDir + "src/main"
        try manifestDir.mkpath()
        try GradleBuildFiles.writeAndroidManifest(
            to: manifestDir,
            packageName: packageName,
            appName: appName,
            sdlVersion: sdlVersion
        )
        
        // Java SDLActivity bridge
        let javaDir = manifestDir + "java" + packageName.replacingOccurrences(of: ".", with: "/")
        try javaDir.mkpath()
        try GradleBuildFiles.writeMainActivity(
            to: javaDir,
            packageName: packageName,
            sdlVersion: sdlVersion
        )
        
        // Build CPython for Android (cached in .psproject/)
        let pyfw = PyFrameworkBackend()
        try await pyfw.installAndroid(
            workingDir: workingDir,
            archs: archs,
            sdk: android?.sdk,
            ndk: android?.ndk
        )
        
        // Copy libpython to jniLibs per architecture
        for arch in archs {
            let prefix = pyfw.androidPrefix(workingDir: workingDir, arch: arch)
            let srcLib = prefix + "lib/libpython\(pyfw.version).so"
            let jniAbi = manifestDir + "jniLibs/\(arch)"
            try jniAbi.mkpath()
            let dstLib = jniAbi + "libpython\(pyfw.version).so"
            if !dstLib.exists {
                try srcLib.copy(dstLib)
            }
        }
        
        // Copy stdlib from first arch (identical across archs)
        let firstPrefix = pyfw.androidPrefix(workingDir: workingDir, arch: archs[0])
        let stdlibSrc = firstPrefix + "lib/python\(pyfw.version)"
        let assetsDir = manifestDir + "assets"
        try assetsDir.mkpath()
        let stdlibDst = assetsDir + "python\(pyfw.version)"
        if !stdlibDst.exists {
            try stdlibSrc.copy(stdlibDst)
        }
        
        print("Android project generated at: \(distDir)")
        print("  CPython \(pyfw.version) built and installed for: \(archs.joined(separator: ", "))")
        print("  jniLibs/           - libpython\(pyfw.version).so per ABI")
        print("  assets/python\(pyfw.version)/ - Python stdlib")
        print("")
        print("Open in Android Studio or build with: cd \(distDir) && gradle assembleDebug")
    }
}
