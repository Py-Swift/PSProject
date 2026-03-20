//
//  SettingPresets.swift
//  PSProject
//
//  XcodeGen SettingPresets embedded as Swift dictionaries.
//  Source: XcodeGen/SettingPresets/*.yml
//

import ProjectSpec
import XcodeProj

public enum SettingPresets {
    
    public typealias BuildSettings = [String: Any]
    
    // MARK: - Base
    
    public static let base: BuildSettings = [
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "CLANG_ANALYZER_NONNULL": "YES",
        "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
        "CLANG_CXX_LANGUAGE_STANDARD": "gnu++14",
        "CLANG_CXX_LIBRARY": "libc++",
        "CLANG_ENABLE_MODULES": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "CLANG_ENABLE_OBJC_WEAK": "YES",
        "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
        "CLANG_WARN_BOOL_CONVERSION": "YES",
        "CLANG_WARN_COMMA": "YES",
        "CLANG_WARN_CONSTANT_CONVERSION": "YES",
        "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": "YES",
        "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
        "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
        "CLANG_WARN_EMPTY_BODY": "YES",
        "CLANG_WARN_ENUM_CONVERSION": "YES",
        "CLANG_WARN_INFINITE_RECURSION": "YES",
        "CLANG_WARN_INT_CONVERSION": "YES",
        "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
        "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": "YES",
        "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
        "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
        "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",
        "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
        "CLANG_WARN_STRICT_PROTOTYPES": "YES",
        "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
        "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
        "CLANG_WARN_UNREACHABLE_CODE": "YES",
        "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
        "COPY_PHASE_STRIP": "NO",
        "ENABLE_STRICT_OBJC_MSGSEND": "YES",
        "GCC_C_LANGUAGE_STANDARD": "gnu11",
        "GCC_NO_COMMON_BLOCKS": "YES",
        "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
        "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
        "GCC_WARN_UNDECLARED_SELECTOR": "YES",
        "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
        "GCC_WARN_UNUSED_FUNCTION": "YES",
        "GCC_WARN_UNUSED_VARIABLE": "YES",
        "MTL_FAST_MATH": "YES",
        "PRODUCT_NAME": "$(TARGET_NAME)",
        "SWIFT_VERSION": "5.0",
    ]
    
    // MARK: - Configs
    
    public enum Config {
        
        public static let debug: BuildSettings = [
            "DEBUG_INFORMATION_FORMAT": "dwarf",
            "ENABLE_TESTABILITY": "YES",
            "GCC_DYNAMIC_NO_PIC": "NO",
            "GCC_OPTIMIZATION_LEVEL": "0",
            "GCC_PREPROCESSOR_DEFINITIONS": ["$(inherited)", "DEBUG=1"],
            "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
            "ONLY_ACTIVE_ARCH": "YES",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
            "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
        ]
        
        public static let release: BuildSettings = [
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "ENABLE_NS_ASSERTIONS": "NO",
            "MTL_ENABLE_DEBUG_INFO": "NO",
            "SWIFT_COMPILATION_MODE": "wholemodule",
            "SWIFT_OPTIMIZATION_LEVEL": "-O",
        ]
        
    }
    
    // MARK: - Platforms
    
    public enum Platform {
        
        public static let iOS: BuildSettings = [
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks"],
            "SDKROOT": "iphoneos",
            "TARGETED_DEVICE_FAMILY": "1,2",
        ]
        
        public static let macOS: BuildSettings = [
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/../Frameworks"],
            "SDKROOT": "macosx",
            "COMBINE_HIDPI_IMAGES": "YES",
        ]
        
        public static let tvOS: BuildSettings = [
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks"],
            "SDKROOT": "appletvos",
            "TARGETED_DEVICE_FAMILY": "3",
        ]
        
        public static let visionOS: BuildSettings = [
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks"],
            "SDKROOT": "xros",
            "TARGETED_DEVICE_FAMILY": "7",
        ]
        
        public static let watchOS: BuildSettings = [
            "SDKROOT": "watchos",
            "SKIP_INSTALL": "YES",
            "TARGETED_DEVICE_FAMILY": "4",
        ]
        
        public static func settings(for platform: ProjectSpec.Platform) -> BuildSettings {
            switch platform {
            case .iOS: return iOS
            case .macOS: return macOS
            case .tvOS: return tvOS
            case .visionOS: return visionOS
            case .watchOS: return watchOS
            case .auto: return [:]
            @unknown default: return [:]
            }
        }
    }
    
    // MARK: - Supported Destinations
    
    public enum SupportedDestination {
        
        public static let iOS: BuildSettings = [
            "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator",
            "TARGETED_DEVICE_FAMILY": "1,2",
            "SUPPORTS_MACCATALYST": "NO",
            "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "YES",
            "SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD": "YES",
        ]
        
        public static let macCatalyst: BuildSettings = [
            "SUPPORTS_MACCATALYST": "YES",
            "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "NO",
        ]
        
        public static let macOS: BuildSettings = [
            "SUPPORTED_PLATFORMS": "macosx",
            "SUPPORTS_MACCATALYST": "NO",
            "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "NO",
        ]
        
        public static let tvOS: BuildSettings = [
            "SUPPORTED_PLATFORMS": "appletvos appletvsimulator",
            "TARGETED_DEVICE_FAMILY": "3",
        ]
        
        public static let visionOS: BuildSettings = [
            "SUPPORTED_PLATFORMS": "xros xrsimulator",
            "TARGETED_DEVICE_FAMILY": "7",
            "SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD": "NO",
        ]
        
        public static let watchOS: BuildSettings = [
            "SUPPORTED_PLATFORMS": "watchos watchsimulator",
            "TARGETED_DEVICE_FAMILY": "4",
        ]
        
        public static func settings(for destination: ProjectSpec.SupportedDestination) -> BuildSettings {
            switch destination {
            case .iOS: return iOS
            case .macCatalyst: return macCatalyst
            case .macOS: return macOS
            case .tvOS: return tvOS
            case .visionOS: return visionOS
            case .watchOS: return watchOS
            @unknown default: return [:]
            }
        }
    }
    
    // MARK: - Products
    
    public enum Product {
        
        public static let application: BuildSettings = [:]
        
        public static let appExtension: BuildSettings = [
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"],
        ]
        
        public static let appExtensionMessages: BuildSettings = [
            "ASSETCATALOG_COMPILER_APPICON_NAME": "iMessage App Icon",
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"],
        ]
        
        public static let appExtensionIntentsService: BuildSettings = [
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks", "@executable_path/../../../../Frameworks"],
        ]
        
        public static let unitTest: BuildSettings = [
            "BUNDLE_LOADER": "$(TEST_HOST)",
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks"],
        ]
        
        public static let uiTest: BuildSettings = [
            "BUNDLE_LOADER": "$(TEST_HOST)",
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks"],
        ]
        
        public static let framework: BuildSettings = [
            "CURRENT_PROJECT_VERSION": "1",
            "DEFINES_MODULE": "YES",
            "CODE_SIGN_IDENTITY": "",
            "DYLIB_COMPATIBILITY_VERSION": "1",
            "DYLIB_CURRENT_VERSION": "1",
            "VERSIONING_SYSTEM": "apple-generic",
            "INSTALL_PATH": "$(LOCAL_LIBRARY_DIR)/Frameworks",
            "DYLIB_INSTALL_NAME_BASE": "@rpath",
            "SKIP_INSTALL": "YES",
        ]
        
        public static let staticFramework: BuildSettings = [
            "CURRENT_PROJECT_VERSION": "1",
            "DEFINES_MODULE": "YES",
            "CODE_SIGN_IDENTITY": "",
            "DYLIB_COMPATIBILITY_VERSION": "1",
            "DYLIB_CURRENT_VERSION": "1",
            "VERSIONING_SYSTEM": "apple-generic",
            "INSTALL_PATH": "$(LOCAL_LIBRARY_DIR)/Frameworks",
            "DYLIB_INSTALL_NAME_BASE": "@rpath",
            "SKIP_INSTALL": "YES",
        ]
        
        public static let staticLibrary: BuildSettings = [
            "SKIP_INSTALL": "YES",
        ]
        
        public static let tvAppExtension: BuildSettings = [
            "SKIP_INSTALL": "YES",
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"],
        ]
        
        public static let watchKit2Extension: BuildSettings = [
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"],
            "ASSETCATALOG_COMPILER_COMPLICATION_NAME": "Complication",
        ]
    }
    
    // MARK: - Product + Platform combos
    
    public enum ProductPlatform {
        
        public static let application_iOS: BuildSettings = [
            "CODE_SIGN_IDENTITY": "iPhone Developer",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        ]
        
        public static let application_macOS: BuildSettings = [
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        ]
        
        public static let application_tvOS: BuildSettings = [
            "ASSETCATALOG_COMPILER_APPICON_NAME": "App Icon & Top Shelf Image",
            "ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME": "LaunchImage",
        ]
        
        public static let application_visionOS: BuildSettings = [
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        ]
        
        public static let application_watchOS: BuildSettings = [
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        ]
        
        public static let appExtension_macOS: BuildSettings = [
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/../Frameworks", "@executable_path/../../../../Frameworks"],
        ]
        
        public static let unitTest_macOS: BuildSettings = [
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/../Frameworks", "@loader_path/../Frameworks"],
        ]
    }
    
    // MARK: - Helpers
    
    /// Merge multiple BuildSettings dictionaries in order (later values override earlier).
    public static func merged(_ settings: BuildSettings...) -> BuildSettings {
        var result: BuildSettings = [:]
        for s in settings {
            result.merge(s) { _, new in new }
        }
        return result
    }
    
    /// Project-level preset settings for a given config type.
    /// Replicates XcodeGen's `getProjectBuildSettings` preset logic.
    public static func projectSettings(configType: ProjectSpec.ConfigType) -> BuildSettings {
        switch configType {
        case .debug:
            return merged(base, Config.debug)
        case .release:
            return merged(base, Config.release)
        }
    }
    
    /// Target-level preset settings for a given platform and product type.
    /// Replicates XcodeGen's `getTargetBuildSettings` preset logic.
    public static func targetSettings(
        platform: ProjectSpec.Platform,
        productType: PBXProductType = .application
    ) -> BuildSettings {
        let platformSettings = Platform.settings(for: platform)
        
        let productSettings: BuildSettings
        switch productType {
        case .application:          productSettings = Product.application
        case .appExtension:         productSettings = Product.appExtension
        case .unitTestBundle:       productSettings = Product.unitTest
        case .uiTestBundle:         productSettings = Product.uiTest
        case .framework:            productSettings = Product.framework
        case .staticFramework:      productSettings = Product.staticFramework
        case .staticLibrary:        productSettings = Product.staticLibrary
        default:                    productSettings = [:]
        }
        
        let comboSettings: BuildSettings
        switch (productType, platform) {
        case (.application, .iOS):      comboSettings = ProductPlatform.application_iOS
        case (.application, .macOS):    comboSettings = ProductPlatform.application_macOS
        case (.application, .tvOS):     comboSettings = ProductPlatform.application_tvOS
        case (.application, .visionOS): comboSettings = ProductPlatform.application_visionOS
        case (.application, .watchOS):  comboSettings = ProductPlatform.application_watchOS
        case (.appExtension, .macOS):   comboSettings = ProductPlatform.appExtension_macOS
        case (.unitTestBundle, .macOS): comboSettings = ProductPlatform.unitTest_macOS
        default:                        comboSettings = [:]
        }
        
        return merged(platformSettings, productSettings, comboSettings)
    }
    
    /// Supported-destinations preset settings for a set of destinations.
    /// Replicates XcodeGen's supported destinations merging (SUPPORTED_PLATFORMS and
    /// TARGETED_DEVICE_FAMILY are concatenated across destinations).
    public static func supportedDestinationSettings(
        _ destinations: [ProjectSpec.SupportedDestination]
    ) -> BuildSettings {
        var result: BuildSettings = [:]
        var supportedPlatforms: [String] = []
        var targetedDeviceFamily: [String] = []
        
        let sorted = destinations.sorted { $0.priority < $1.priority }
        for dest in sorted {
            let s = SupportedDestination.settings(for: dest)
            result.merge(s) { _, new in new }
            
            if let platforms = s["SUPPORTED_PLATFORMS"] as? String {
                supportedPlatforms += platforms.components(separatedBy: " ")
            }
            if let family = s["TARGETED_DEVICE_FAMILY"] as? String {
                targetedDeviceFamily += family.components(separatedBy: ",")
            }
        }
        
        if !supportedPlatforms.isEmpty {
            result["SUPPORTED_PLATFORMS"] = supportedPlatforms.joined(separator: " ")
        }
        if !targetedDeviceFamily.isEmpty {
            result["TARGETED_DEVICE_FAMILY"] = targetedDeviceFamily.joined(separator: ",")
        }
        
        return result
    }
}
