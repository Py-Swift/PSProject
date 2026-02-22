//
//  XcodeCapability.swift
//  PyProjectToml
//
import JSONUtilities

public enum XcodeCapability: String, Codable {
    case bluetooth
    case camera
    case classkit
    
    
    public var key: String {
        switch self {
            case .bluetooth: "NSBluetoothAlwaysUsageDescription"
            case .camera: "NSCameraUsageDescription"
            case .classkit:
                "com.apple.developer.ClassKit-environment"
        }
    }
    
    
    func info_plist_items() -> JSONDictionary {
        switch self {
            case .bluetooth:
                ["NSBluetoothAlwaysUsageDescription":""]
            case .camera:
                ["NSCameraUsageDescription":""]
            case .classkit:
                [:]
        }
    }
    
    func entitlement_items() -> JSONDictionary {
        switch self {
            case .bluetooth:
                [:]
            case .camera:
                [:]
            case .classkit:
                ["com.apple.developer.ClassKit-environment":"development"]
        }
    }
}
