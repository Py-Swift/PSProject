# MobilePlatformSupport

A Swift package for checking mobile platform (Android/iOS) support for Python packages on PyPI. This is a Swift equivalent of the [beeware/mobile-wheels](https://github.com/beeware/mobile-wheels) `utils.py` functionality.

## Overview

This package helps you determine whether Python packages have binary wheel support for mobile platforms (Android and iOS). It's particularly useful when building mobile applications with Python, as many packages with C extensions need specific wheels compiled for mobile architectures.

## Features

- ✅ Check if a Python package has binary wheels (not pure Python)
- ✅ Detect platform support for Android and iOS
- ✅ Filter out deprecated and non-mobile packages
- ✅ Async/await API for efficient network operations
- ✅ Built-in lists of packages known to be incompatible with mobile

## Installation

Add this package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(path: "../MobilePlatformSupport")
]
```

## Usage

### Basic Usage - Check if a Package is Binary

```swift
import MobilePlatformSupport

let checker = MobilePlatformSupport()

// Check if numpy has binary wheels
let isBinary = try await checker.isBinaryPackage("numpy")
print("numpy is binary: \(isBinary)") // true
```

### Get Platform Support Information

```swift
import MobilePlatformSupport

let checker = MobilePlatformSupport()

// Get full platform support details
if let packageInfo = try await checker.annotatePackage("numpy") {
    print("Package: \(packageInfo.name)")
    print("Android support: \(packageInfo.android?.rawValue ?? "unknown")")
    print("iOS support: \(packageInfo.ios?.rawValue ?? "unknown")")
}
```

### Check Multiple Packages

```swift
import MobilePlatformSupport

let checker = MobilePlatformSupport()

let packages = ["numpy", "pandas", "pillow", "cryptography", "lxml"]

// Get all binary packages with platform support
let binaryPackages = try await checker.getBinaryPackages(from: packages)

for package in binaryPackages {
    print("\(package.name):")
    print("  Android: \(package.android?.rawValue ?? "unknown")")
    print("  iOS: \(package.ios?.rawValue ?? "unknown")")
}
```

### Filter Only Binary Packages

```swift
import MobilePlatformSupport

let checker = MobilePlatformSupport()

let allPackages = ["numpy", "requests", "pillow", "click", "pyyaml"]

// Get only the names of packages with binary wheels
let binaryOnly = try await checker.filterBinaryPackages(from: allPackages)
print("Binary packages: \(binaryOnly)")
// Output: ["numpy", "pillow", "pyyaml"]
```

## Platform Support Types

The package returns one of three support levels for each platform:

- **`success`**: Has compiled binary wheels for the platform ✅
- **`pure-py`**: Only has pure Python wheels (will likely work but may have reduced performance) 🐍
- **`warning`**: No wheels available for the platform ⚠️

## Excluded Packages

The package automatically excludes:

### Deprecated Packages
- BeautifulSoup, bs4, distribute, django-social-auth, nose, pep8, pycrypto, pypular, sklearn, subprocess32

### Non-Mobile Packages
- **CUDA/Nvidia packages**: Not available on mobile platforms
- **Intel-specific packages**: Intel processors not used on mobile
- **Subprocess-based packages**: Subprocesses not well supported on mobile
- **Windows-specific packages**: Not relevant for mobile platforms

See `MobilePlatformSupport.deprecatedPackages` and `MobilePlatformSupport.nonMobilePackages` for complete lists.

## API Reference

### `MobilePlatformSupport`

Main class for checking platform support.

#### Methods

- `init(session: URLSession = .shared)`: Initialize with optional custom URLSession
- `isBinaryPackage(_ packageName: String) async throws -> Bool`: Check if package has binary wheels
- `annotatePackage(_ packageName: String) async throws -> PackageInfo?`: Get full platform support info
- `getBinaryPackages(from: [String], maxResults: Int? = nil) async throws -> [PackageInfo]`: Process multiple packages
- `filterBinaryPackages(from: [String]) async throws -> [String]`: Get only binary package names

### `PackageInfo`

```swift
struct PackageInfo {
    let name: String
    var android: PlatformSupport?
    var ios: PlatformSupport?
}
```

### `PlatformSupport`

```swift
enum PlatformSupport: String {
    case success = "success"     // Has compiled wheels
    case purePython = "pure-py"  // Pure Python only
    case warning = "warning"     // No wheels available
}
```

### `MobilePlatform`

```swift
enum MobilePlatform: String {
    case android
    case ios
}
```

## Error Handling

```swift
do {
    let info = try await checker.annotatePackage("numpy")
    // Use info
} catch MobilePlatformError.invalidPackageName(let name) {
    print("Invalid package: \(name)")
} catch MobilePlatformError.httpError(let code) {
    print("HTTP error: \(code)")
} catch {
    print("Other error: \(error)")
}
```

## Implementation Details

This Swift package mirrors the functionality of the Python `utils.py` from [beeware/mobile-wheels](https://github.com/beeware/mobile-wheels):

- Fetches package metadata from PyPI JSON API
- Parses wheel filenames to extract platform tags
- Follows the [wheel filename convention](https://packaging.python.org/en/latest/specifications/binary-distribution-format/#file-name-convention)
- Filters out pure Python wheels (platform tag = "any")

## Related Resources

- [beeware/mobile-wheels](https://github.com/beeware/mobile-wheels) - Original Python implementation
- [Mobile Wheels Website](http://beeware.org/mobile-wheels/) - Visual dashboard of mobile package support
- [KIVY_LIBRARY_GUIDELINES.md](../KIVY_LIBRARY_GUIDELINES.md) - Guidelines for creating mobile-compatible libraries

## License

This package is part of the PSProject ecosystem.
