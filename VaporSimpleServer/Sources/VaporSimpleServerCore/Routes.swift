import Vapor
import Foundation

public func registerRoutes(_ app: Application, wheelDir: String) {

    app.get("simple") { req -> Response in
        let scanner = WheelScanner(root: wheelDir)
        let packages = try scanner.scan()
        let html = HTMLRenderer.simpleIndexPage(packages: packages.map(\.name))
        return htmlResponse(html)
    }

    app.get("simple", ":package") { req -> Response in
        guard let packageName = req.parameters.get("package") else {
            throw Abort(.badRequest, reason: "Missing package name")
        }

        let scanner = WheelScanner(root: wheelDir)
        let packages = try scanner.scan()

        if let package = packages.first(where: { $0.name == packageName }) {
            req.logger.info("Found package '\(packageName)' with \(package.files.count) file(s)")
            let html = HTMLRenderer.packagePage(name: packageName, files: package.files)
            return htmlResponse(html)
        } else {
            return Response(status: .notFound)
        }
    }

    app.get("packages", ":filename") { req -> Response in
        guard let filename = req.parameters.get("filename") else {
            throw Abort(.badRequest, reason: "Missing filename")
        }

        // Only serve wheel and archive files
        guard filename.hasSuffix(".whl") || filename.hasSuffix(".gz") else {
            throw Abort(.forbidden, reason: "Only .whl and .gz files can be served")
        }

        let fileURL = URL(fileURLWithPath: wheelDir).appendingPathComponent(filename)
        let filePath = fileURL.path

        guard FileManager.default.fileExists(atPath: filePath) else {
            throw Abort(.notFound, reason: "File '\(filename)' not found")
        }

        return try await req.fileio.asyncStreamFile(at: filePath)
    }
}

func htmlResponse(_ html: String) -> Response {
    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "text/html; charset=utf-8")
    return Response(status: .ok, headers: headers, body: .init(string: html))
}
