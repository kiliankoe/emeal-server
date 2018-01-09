import Vapor

public class Log {
    public static weak var droplet: Droplet?

    public static func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        Log.droplet?.log.log(level, message: message, file: file, function: function, line: line)
    }

    public static func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Log.log(level: .verbose, message: message, file: file, function: function, line: line)
    }

    public static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Log.log(level: .debug, message: message, file: file, function: function, line: line)
    }

    public static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Log.log(level: .info, message: message, file: file, function: function, line: line)
    }

    public static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Log.log(level: .warning, message: message, file: file, function: function, line: line)
    }

    public static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Log.log(level: .error, message: message, file: file, function: function, line: line)
    }

    public static func fatal(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Log.log(level: .fatal, message: message, file: file, function: function, line: line)
    }
}
