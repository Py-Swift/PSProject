public enum HTMLRenderer: Sendable {

    public static func simpleIndexPage(packages: [String]) -> String {
        let links = packages.map { name in
            "<a href=\"/simple/\(name)/\">\(name)</a><br>"
        }.joined(separator: "\n")

        return """
        <!DOCTYPE html>
        <html>
        <body>
        \(links)
        </body>
        </html>
        """
    }

    public static func packagePage(name: String, files: [String]) -> String {
        let links = files.map { filename in
            "<a href=\"/packages/\(filename)\">\(filename)</a><br>"
        }.joined(separator: "\n")

        return """
        <!DOCTYPE html>
        <html>
        <body>
        <h1>\(name)</h1>
        \(links)
        </body>
        </html>
        """
    }
}
