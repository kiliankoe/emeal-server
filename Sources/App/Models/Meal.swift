import Vapor
import FluentProvider
import HTTP

typealias ISODate = String

final class Meal: Model {
    let storage = Storage()

    let title: String
    let canteen: String
    let date: ISODate

    let isSoldOut: Bool
    let studentPrice: Double?
    let employeePrice: Double?
    let image: String?
    let detailURL: String
    let ingredients: [String]
    let additives: [String]
    let allergens: [String]

    init(title: String,
         canteen: String,
         date: ISODate,
         isSoldOut: Bool,
         studentPrice: Double?,
         employeePrice: Double?,
         image: String?,
         detailURL: String,
         ingredients: [String],
         additives: [String],
         allergens: [String]) {
            self.title = title
            self.canteen = canteen
            self.date = date
            self.isSoldOut = isSoldOut
            self.studentPrice = studentPrice
            self.employeePrice = employeePrice
            self.image = image
            self.detailURL = detailURL
            self.ingredients = ingredients
            self.additives = additives
            self.allergens = allergens
    }

    enum Keys {
        static let title = "title"
        static let canteen = "canteen"
        static let date = "date"
        static let isSoldOut = "isSoldOut"
        static let studentPrice = "studentPrice"
        static let employeePrice = "employeePrice"
        static let image = "image"
        static let detailURL = "detailURL"
        static let ingredients = "ingredients"
        static let additives = "additives"
        static let allergens = "allergens"
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.title, self.title)
        try row.set(Keys.canteen, self.canteen)
        try row.set(Keys.date, self.date)
        try row.set(Keys.isSoldOut, self.isSoldOut)
        try row.set(Keys.studentPrice, self.studentPrice)
        try row.set(Keys.employeePrice, self.employeePrice)
        try row.set(Keys.image, self.image)
        try row.set(Keys.detailURL, self.detailURL)
        try row.set(Keys.ingredients, self.ingredients.semicolonStr)
        try row.set(Keys.additives, self.additives.semicolonStr)
        try row.set(Keys.allergens, self.allergens.semicolonStr)
        return row
    }

    init(row: Row) throws {
        self.title = try row.get(Keys.title)
        self.canteen = try row.get(Keys.canteen)
        self.date = try row.get(Keys.date)
        self.isSoldOut = try row.get(Keys.isSoldOut)
        self.studentPrice = try row.get(Keys.studentPrice)
        self.employeePrice = try row.get(Keys.employeePrice)
        self.image = try row.get(Keys.image)
        self.detailURL = try row.get(Keys.detailURL)

        let ingredients: String = try row.get(Keys.ingredients)
        self.ingredients = ingredients.semicolonArr

        let additives: String = try row.get(Keys.additives)
        self.additives = additives.semicolonArr

        let allergens: String = try row.get(Keys.allergens)
        self.allergens = allergens.semicolonArr
    }
}

extension Meal: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.title)
            builder.string(Keys.canteen)
            builder.string(Keys.date)
            builder.bool(Keys.isSoldOut)
            builder.double(Keys.studentPrice, optional: true)
            builder.double(Keys.employeePrice, optional: true)
            builder.string(Keys.image, optional: true)
            builder.string(Keys.detailURL)
            builder.string(Keys.ingredients)
            builder.string(Keys.additives)
            builder.string(Keys.allergens)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Meal: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.title, self.title)
        try json.set(Keys.canteen, self.canteen)
        try json.set(Keys.date, self.date)
        try json.set(Keys.isSoldOut, self.isSoldOut)
        try json.set(Keys.studentPrice, self.studentPrice)
        try json.set(Keys.employeePrice, self.employeePrice)
        try json.set(Keys.image, self.image)
        try json.set(Keys.detailURL, self.detailURL)
        try json.set(Keys.ingredients, self.ingredients)
        try json.set(Keys.additives, self.additives)
        try json.set(Keys.allergens, self.allergens)
        return json
    }

    convenience init(json: JSON) throws {
        self.init(title: try json.get(Keys.title),
                  canteen: try json.get(Keys.canteen),
                  date: try json.get(Keys.date),
                  isSoldOut: try json.get(Keys.isSoldOut),
                  studentPrice: try json.get(Keys.studentPrice),
                  employeePrice: try json.get(Keys.employeePrice),
                  image: try json.get(Keys.image),
                  detailURL: try json.get(Keys.detailURL),
                  ingredients: try json.get(Keys.ingredients),
                  additives: try json.get(Keys.additives),
                  allergens: try json.get(Keys.allergens))
    }
}

extension Meal: ResponseRepresentable { }
