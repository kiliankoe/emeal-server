import Foundation
import Dispatch

enum Network {
    static func fetch(url: URL) -> String? {
        let sema = DispatchSemaphore(value: 0)
        var body: String?

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        var request = URLRequest(url: url)
        request.addValue("emeal-server v0.1.0 <emeal@fastmail.com> https://github.com/kiliankoe/emeal-server", forHTTPHeaderField: "User-Agent")
        request.addValue("de-DE", forHTTPHeaderField: "Accept-Language")

        Log.verbose("↪ \(url.absoluteString)")
        let task = session.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let data = data,
                let content = String(data: data, encoding: .utf8),
                let response = response as? HTTPURLResponse,
                response.statusCode/100 == 2
            else {
                Log.error("Network error: \(String(describing: error))")
                body = nil
                sema.signal()
                return
            }
            body = content
            sema.signal()
        }

        task.resume()
        sema.wait()

        return body
    }
}
