@preconcurrency import PathKit
import Algorithms

public struct WheelPackage: Sendable {
    public let name: String
    public let files: [String]

    public init(name: String, files: [String]) {
        self.name = name
        self.files = files
    }
}

public struct WheelScanner: Sendable {

    public let root: String

    public init(root: String) {
        self.root = root
    }

    public init(root: Path) {
        self.root = root.string
    }

    public func scan() throws -> [WheelPackage] {
        let rootPath = Path(root)
        let children = try rootPath.children()
            .filter(\.whl_or_gz)
            .sorted()

        let groups = children.chunked(on: \.whl_name)
        return groups.map { name, wheels in
            WheelPackage(
                name: name,
                files: wheels.map(\.lastComponent)
            )
        }
    }
}

extension Path {
    var whl_or_gz: Bool {
        self.extension == "whl" || self.extension == "gz"
    }

    var whl_name: String {
        lastComponent.split(whereSeparator: { $0 == "-" }).first!.lowercased()
    }
}
