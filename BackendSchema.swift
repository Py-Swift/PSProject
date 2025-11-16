import Foundation

// MARK: - Backend Configuration

struct BackendConfig: Codable {
    let name: String
    let backendDependencies: [String]?
    let excludeDependencies: [String]?
    let downloads: [String]?
    let frameworks: [String]?
    let targetDependencies: [TargetDependency]?
    let packages: [String: Package]?
    let wrapperImports: [String: WrapperImport]?
    let install: [ScriptConfig]?
    let copyToSitePackages: [ScriptConfig]?
    let plistEntries: [String: AnyCodable]?
    let willModifyMainSwift: [String: Bool]?
    let modifyMainSwift: [ScriptConfig]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case backendDependencies = "backend_dependencies"
        case excludeDependencies = "exclude_dependencies"
        case downloads
        case frameworks
        case targetDependencies = "target_dependencies"
        case packages
        case wrapperImports = "wrapper_imports"
        case install
        case copyToSitePackages = "copy_to_site_packages"
        case plistEntries = "plist_entries"
        case willModifyMainSwift = "will_modify_main_swift"
        case modifyMainSwift = "modify_main_swift"
    }
}

// MARK: - Target Dependency

struct TargetDependency: Codable {
    let type: DependencyType
    let reference: String
    let products: [String]?
    let platformFilter: PlatformFilter?
    
    enum CodingKeys: String, CodingKey {
        case type
        case reference
        case products
        case platformFilter = "platformFilter"
    }
}

enum DependencyType: String, Codable {
    case framework
    case package
}

enum PlatformFilter: String, Codable {
    case iOS
    case macOS
    case tvOS
    case watchOS
    case visionOS
}

// MARK: - Package

struct Package: Codable {
    let url: String?
    let path: String?
    let revision: String?
    let branch: String?
    let exactVersion: String?
    let versionRange: VersionRange?
    let upToNextMinorVersion: String?
    let upToNextMajorVersion: String?
    let versionRequirement: VersionRequirement?
    
    enum CodingKeys: String, CodingKey {
        case url
        case path
        case revision
        case branch
        case exactVersion
        case versionRange
        case upToNextMinorVersion
        case upToNextMajorVersion
        case versionRequirement
    }
}

struct VersionRange: Codable {
    let minimumVersion: String
    let maximumVersion: String
}

enum VersionRequirement: Codable {
    case branch(String)
    case version(String)
    case revision(String)
    
    enum CodingKeys: String, CodingKey {
        case branch
        case version
        case revision
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let branch = try? container.decode(String.self, forKey: .branch) {
            self = .branch(branch)
        } else if let version = try? container.decode(String.self, forKey: .version) {
            self = .version(version)
        } else if let revision = try? container.decode(String.self, forKey: .revision) {
            self = .revision(revision)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid version requirement"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .branch(let value):
            try container.encode(value, forKey: .branch)
        case .version(let value):
            try container.encode(value, forKey: .version)
        case .revision(let value):
            try container.encode(value, forKey: .revision)
        }
    }
}

// MARK: - Wrapper Import

struct WrapperImport: Codable {
    let libraries: [String]?
    let modules: [String]?
}

// MARK: - Script Configuration

struct ScriptConfig: Codable {
    let type: ScriptType
    let shell: ShellType?
    let file: String?
    let run: String?
}

enum ScriptType: String, Codable {
    case shell
}

enum ShellType: String, Codable {
    case python
    case bash
    case zsh
    case sh
    case ruby
    case fish
}

// MARK: - AnyCodable Helper

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "AnyCodable value cannot be encoded"
                )
            )
        }
    }
}
