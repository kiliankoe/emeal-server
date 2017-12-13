import Foundation
import Vapor
import FluentProvider
import HTTP

final class Menu: Model {
    let storage = Storage()

    let date: Date
    var dateStamp: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: self.date)
        }
    }
    let meals: [Meal]

    enum Keys {
        static let date = "date"
        static let meals = "meals"
    }

    init(date: Date, meals: [Meal]) {
        self.date = date
        self.meals = meals
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.date, self.date)
        try row.set(Keys.meals, self.meals)
        return row
    }

    init(row: Row) throws {
        self.date = try row.get(Keys.date)
        self.meals = try row.get(Keys.meals)
    }
}

extension Menu: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.date(Keys.date)
            builder.foreignId(for: Meal.self)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Menu: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.date, self.dateStamp)
        try json.set(Keys.meals, self.meals)
        return json
    }
}

extension Menu: ResponseRepresentable { }
