
import Basic
import Foundation

public struct Shell {
    private init() {}
    public static var isDryRun: Bool = false

    public static func run(_ command: String..., exitOnFailure: Bool = true) {
        let cmd = command.joined(separator: " ")
        Logger.info(cmd)
        guard !isDryRun else { return }
        let process = Foundation.Process()
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", cmd]
        process.standardOutput = FileHandle.standardOutput
        let errorPipe = Pipe()
        process.standardError = errorPipe
        process.launch()
        process.waitUntilExit()

        let status = process.terminationStatus
        if status != 0 {
            Logger.error("Error running the following command:")
            Logger.info("\t" + cmd)
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if let error = String(data: data, encoding: .utf8) {
                Logger.error(error)
            }
            if exitOnFailure {
                exit(status)
            }
        }
    }
}

public enum Logger {
    private static let terminal: TerminalController? = {
        guard let stdout = stdoutStream as? LocalFileOutputByteStream else { return nil }
        return TerminalController(stream: stdout)
    }()

    public static func status(_ message: String) {
        terminal?.write("➜ " + message, inColor: .cyan, bold: true)
        terminal?.endLine()
    }

    public static func info(_ message: String) {
        terminal?.write("➜ " + message, inColor: .green, bold: true)
        terminal?.endLine()
    }

    public static func error(_ message: String) {
        terminal?.write("➜ " + message, inColor: .red, bold: true)
        terminal?.endLine()
    }
}
