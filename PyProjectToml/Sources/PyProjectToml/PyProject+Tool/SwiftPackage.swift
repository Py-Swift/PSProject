//
//  SwiftPackage.swift
//  PyProjectToml
//
import JSONUtilities


extension Tool.PSProject {
    public enum SwiftPackage: Decodable {
        case path(PathData)
        case url(URLData)
        
        public var json: JSONDictionary {
            switch self {
                case .path(let pathData):
                    [
                        "path" : pathData.path
                    ]
                case .url(let uRLData):
                    [
                        "url" : uRLData.url
                    ].merged(uRLData.version.json)
            }
        }
        
        enum CodingKeys: CodingKey {
            case path
            case url
            
            case revision
            case branch
            case minimumVersion
            case maximumVersion
            case version
            case upToNextMinor
            case upToNextMajor
            case from
        }
        
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let allKeys = container.allKeys
            
            self = try {
                if allKeys.contains(.path) {
                    return .path(try container.decode(PathData.self, forKey: .path))
                } else {
                    let version: VersionRequirement = switch allKeys {
                        case _ where allKeys.contains(.branch):
                                .branch(try container.decode(String.self, forKey: .branch))
                        case _ where allKeys.contains(.revision):
                                .revision(try container.decode(String.self, forKey: .revision))
                        case _ where allKeys.contains(.version):
                                .exact(try container.decode(String.self, forKey: .version))
                        case _ where allKeys.contains(.upToNextMinor):
                                .upToNextMinorVersion(try container.decode(String.self, forKey: .upToNextMinor))
                        case _ where allKeys.contains(.upToNextMajor):
                                .upToNextMajorVersion(try container.decode(String.self, forKey: .upToNextMajor))
                        default:
                            fatalError("XCRemoteSwiftPackageReference  keys is missing")
                    }
                    
                   return  .url(
                        .init(
                            url: try container.decode(String.self, forKey: .url),
                            version: version
                        )
                    )
                }
            }()
        }
    }
    
    
}

public extension Tool.PSProject.SwiftPackage {
    struct PathData: Decodable {
        let path: String
    }
    
    struct URLData: Decodable {
        internal init(url: String, version: Tool.PSProject.SwiftPackage.VersionRequirement) {
            self.url = url
            self.version = version
        }
        
        let url: String
        let version: VersionRequirement
        
//        enum CodingKeys: CodingKey {
//            case path
//            case url
//            
//            case revision
//            case branch
//            case minimumVersion
//            case maximumVersion
//            case version
//            case upToNextMinor
//            case upToNextMajor
//            case from
//        }
        
        
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            //let kind: String = try container.decode(String.self, forKey: .kind)
            let allKeys = container.allKeys
            switch allKeys {
                case _ where allKeys.contains(.branch):
                    version = .branch(try container.decode(String.self, forKey: .branch))
                case _ where allKeys.contains(.revision):
                    version = .revision(try container.decode(String.self, forKey: .revision))
                case _ where allKeys.contains(.version):
                    version = .exact(try container.decode(String.self, forKey: .version))
                case _ where allKeys.contains(.upToNextMinor):
                    version = .upToNextMinorVersion(try container.decode(String.self, forKey: .upToNextMinor))
                case _ where allKeys.contains(.upToNextMajor):
                    version = .upToNextMajorVersion(try container.decode(String.self, forKey: .upToNextMajor))
                default:
                    fatalError("XCRemoteSwiftPackageReference  keys is missing")
            }
            url = try container.decode(String.self, forKey: .url)
        }
        
        
    }
    
    public enum VersionRequirement: Decodable, Equatable {
        case upToNextMajorVersion(String)
        case upToNextMinorVersion(String)
        case range(from: String, to: String)
        case exact(String)
        case branch(String)
        case revision(String)
        
        enum CodingKeys: String, CodingKey {
            case kind
            case revision
            case branch
            case minimumVersion
            case maximumVersion
            case version
            case upToNextMinor
            case upToNextMajor
            case from
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            //let kind: String = try container.decode(String.self, forKey: .kind)
            let allKeys = container.allKeys
            switch allKeys {
                case _ where allKeys.contains(.branch):
                    self = .branch(try container.decode(String.self, forKey: .branch))
                case _ where allKeys.contains(.revision):
                    self = .revision(try container.decode(String.self, forKey: .revision))
                case _ where allKeys.contains(.version):
                    self = .exact(try container.decode(String.self, forKey: .version))
                case _ where allKeys.contains(.upToNextMinor):
                    self = .upToNextMinorVersion(try container.decode(String.self, forKey: .upToNextMinor))
                case _ where allKeys.contains(.upToNextMajor):
                    self = .upToNextMajorVersion(try container.decode(String.self, forKey: .upToNextMajor))
                default:
                    fatalError("XCRemoteSwiftPackageReference keys missing \(allKeys.map(\.stringValue))")
            }
            
//            if kind == "revision" {
//                let revision = try container.decode(String.self, forKey: .revision)
//                self = .revision(revision)
//            } else if kind == "branch" {
//                let branch = try container.decode(String.self, forKey: .branch)
//                self = .branch(branch)
//            } else if kind == "exactVersion" {
//                let version = try container.decode(String.self, forKey: .version)
//                self = .exact(version)
//            } else if kind == "versionRange" {
//                let minimumVersion = try container.decode(String.self, forKey: .minimumVersion)
//                let maximumVersion = try container.decode(String.self, forKey: .maximumVersion)
//                self = .range(from: minimumVersion, to: maximumVersion)
//            } else if kind == "upToNextMinorVersion" {
//                let version = try container.decode(String.self, forKey: .minimumVersion)
//                self = .upToNextMinorVersion(version)
//            } else if kind == "upToNextMajorVersion" {
//                let version = try container.decode(String.self, forKey: .minimumVersion)
//                self = .upToNextMajorVersion(version)
//            } else {
//                fatalError("XCRemoteSwiftPackageReference kind '\(kind)' not supported")
//            }
        }
        
        var json: JSONDictionary {
            switch self {
                case .upToNextMajorVersion(let string):
                    [
                        "kind": "majorVersion",
                        "majorVersion": string
                    ]
                case .upToNextMinorVersion(let string):
                    [
                        "kind": "minorVersion",
                        "minorVersion": string
                    ]
                case .range(let from, let to):
                    [
                        "kind": "versionRange",
                        "minimumVersion": from,
                        "maximumVersion": to
                        
                    ]
                case .exact(let string):
                    [
                        "kind": "exactVersion",
                        "version": string
                    ]
                case .branch(let string):
                    [
                        "kind": "branch",
                        "branch": string
                    ]
                case .revision(let string):
                    [
                        "kind": "revision",
                        "revision": string
                    ]
            }
        }
        
    }
}
