import ArgumentParser
import Vapor
import VaporSimpleServerCore
import Foundation

@main
struct SimpleServer: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "simple-server",
        abstract: "Localhost pip simple index server."
    )

    @ArgumentParser.Option(name: .long, help: "Directory containing .whl / .gz files to serve.")
    var wheelDir: String = FileManager.default.currentDirectoryPath + "/wheels"

    @ArgumentParser.Option(name: .long, help: "Hostname to bind to.")
    var hostname: String = "127.0.0.1"

    @ArgumentParser.Option(name: .long, help: "Port to listen on.")
    var port: Int = 8080

    func run() async throws {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: wheelDir, isDirectory: &isDir), isDir.boolValue else {
            throw ValidationError("Wheel directory does not exist or is not a directory: \(wheelDir)")
        }

        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = try await Application.make(env)

        app.http.server.configuration.hostname = hostname
        app.http.server.configuration.port = port

        app.logger.info("Serving wheels from: \(wheelDir)")
        app.logger.info("Listening on http://\(hostname):\(port)")

        registerRoutes(app, wheelDir: wheelDir)

        try await app.execute()
        try await app.asyncShutdown()
    }
}
