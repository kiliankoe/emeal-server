import Vapor
import HTTP

final class MealController: ResourceRepresentable {
    typealias Model = Canteen

    func index(_ req: Request) throws -> ResponseRepresentable {
        let query = try Meal.makeQuery()

        if let reqQuery = req.query,
            let date: String = try? reqQuery.get("date") {
            try query.filter(Meal.Keys.date, date)
        } else {
            try query.filter(Meal.Keys.date, Date().dateStamp)
        }

        try query.sort(Meal.Keys.canteen, .ascending)
        return try query.all().makeJSON()
    }

    func show(_ req: Request, canteen: Canteen) throws -> ResponseRepresentable {
        let query = try Meal.makeQuery()
        try query.filter(Meal.Keys.canteen, canteen.name)
        try query.sort(Meal.Keys.date, .ascending)
        return try query.all().makeJSON()
    }

    func makeResource() -> Resource<Canteen> {
        return Resource(index: index,
                        show: show)
    }
}

extension MealController: EmptyInitializable { }
