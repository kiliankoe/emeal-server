import Vapor
import HTTP

final class MenuController: ResourceRepresentable {
    typealias Model = Menu

    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Menu.all().makeJSON()
    }

    func show(_ req: Request, menu: Menu) throws -> ResponseRepresentable {
        return try Menu.all().makeJSON() // FIXME
    }

    func makeResource() -> Resource<Menu> {
        return Resource(index: index,
                        show: show)
    }
}

extension MenuController: EmptyInitializable { }
