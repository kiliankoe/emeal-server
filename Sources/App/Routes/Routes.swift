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

        get("search") { req in
            guard let query: String = try req.query?.get("query") else {
                throw Abort(.badRequest, reason: "Missing parameter `query`.")
            }

            return try Meal.makeQuery()
                .filter(Meal.Keys.title, .contains, query)
                .sort(Meal.Keys.date, .ascending)
                .all()
                .makeJSON()
        }
    }
}
