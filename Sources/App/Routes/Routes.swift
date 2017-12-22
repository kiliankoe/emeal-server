import Vapor

extension Droplet {
    func setupRoutes() throws {
        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        try resource("canteens", CanteenController.self)
        try resource("meals", MealController.self)
    }
}
