import Vapor
import HTTP

final class CanteenController: ResourceRepresentable {
    typealias Model = Canteen

    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Canteen.all().makeJSON()
    }

    func show(_ req: Request, canteen: Canteen) throws -> ResponseRepresentable {
        return canteen
    }

    func makeResource() -> Resource<Canteen> {
        return Resource(
            index: index,
            show: show
        )
    }
}

extension CanteenController: EmptyInitializable { }
