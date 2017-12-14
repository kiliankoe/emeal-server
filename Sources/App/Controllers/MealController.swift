import Vapor
import HTTP

final class MealController: ResourceRepresentable {
    typealias Model = Canteen

    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Meal
            .all()
            .filter { $0.date == Date().dateStamp }
            .makeJSON()
    }

    func show(_ req: Request, canteen: Canteen) throws -> ResponseRepresentable {
        return try Meal
            .all()
            .filter { $0.canteen == canteen.name }
            .makeJSON()
    }

    func makeResource() -> Resource<Canteen> {
        return Resource(index: index,
                        show: show)
    }
}

extension MealController: EmptyInitializable { }
