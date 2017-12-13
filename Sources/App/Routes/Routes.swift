import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("update") { req in
            return "true"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        try resource("canteens", CanteenController.self)
    }
}
