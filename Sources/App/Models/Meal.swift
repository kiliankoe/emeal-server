import Vapor
import FluentProvider
import HTTP

final class Meal: Model {
    let storage = Storage()

    let title: String
    let studentPrice: Double
    let employeePrice: Double
    let image: String?
    let canteen: String
    let detailURL: String
    let type: String
    let counter: String
    let ingredients: [String]
    let additives: [String]
    let allergens: [String]
    let notes: [String]

    init(title: String,
         studentPrice: Double,
         employeePrice: Double,
         image: String?,
         canteen: String,
         detailURL: String,
         type: String,
         counter: String,
         ingredients: [String],
         additives: [String],
         allergens: [String],
         notes: [String]) {
            self.title = title
            self.studentPrice = studentPrice
            self.employeePrice = employeePrice
            self.image = image
            self.canteen = canteen
            self.detailURL = detailURL
            self.type = type
            self.counter = counter
            self.ingredients = ingredients
            self.additives = additives
            self.allergens = allergens
            self.notes = notes
    }

    enum Keys {
        static let title = "title"
        static let studentPrice = "studentPrice"
        static let employeePrice = "employeePrice"
        static let image = "image"
        static let canteen = "canteen"
        static let detailURL = "detailURL"
        static let type = "type"
        static let counter = "counter"
        static let ingredients = "ingredients"
        static let additives = "additives"
        static let allergens = "allergens"
        static let notes = "notes"
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.title, self.title)
        try row.set(Keys.studentPrice, self.studentPrice)
        try row.set(Keys.employeePrice, self.employeePrice)
        try row.set(Keys.image, self.image)
        try row.set(Keys.canteen, self.canteen)
        try row.set(Keys.detailURL, self.detailURL)
        try row.set(Keys.type, self.type)
        try row.set(Keys.counter, self.counter)
        try row.set(Keys.ingredients, self.ingredients)
        try row.set(Keys.additives, self.additives)
        try row.set(Keys.allergens, self.allergens)
        try row.set(Keys.notes, self.notes)
        return row
    }

    init(row: Row) throws {
        self.title = try row.get(Keys.title)
        self.studentPrice = try row.get(Keys.studentPrice)
        self.employeePrice = try row.get(Keys.employeePrice)
        self.image = try row.get(Keys.image)
        self.canteen = try row.get(Keys.canteen)
        self.detailURL = try row.get(Keys.detailURL)
        self.type = try row.get(Keys.type)
        self.counter = try row.get(Keys.counter)
        self.ingredients = try row.get(Keys.ingredients)
        self.additives = try row.get(Keys.additives)
        self.allergens = try row.get(Keys.allergens)
        self.notes = try row.get(Keys.notes)
    }
}

extension Meal: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.title)
            builder.double(Keys.studentPrice)
            builder.double(Keys.employeePrice)
            builder.string(Keys.image)
            builder.string(Keys.canteen)
            builder.string(Keys.detailURL)
            builder.string(Keys.type)
            builder.string(Keys.counter)
//            builder.string(Keys.ingredients)
//            builder.string(Keys.additives)
//            builder.string(Keys.allergens)
//            builder.string(Keys.notes)
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
        try json.set(Keys.title, self.title)
        try json.set(Keys.studentPrice, self.studentPrice)
        try json.set(Keys.employeePrice, self.employeePrice)
        try json.set(Keys.image, self.image)
        try json.set(Keys.canteen, self.canteen)
        try json.set(Keys.detailURL, self.detailURL)
        try json.set(Keys.type, self.type)
        try json.set(Keys.counter, self.counter)
        try json.set(Keys.ingredients, self.ingredients)
        try json.set(Keys.additives, self.additives)
        try json.set(Keys.allergens, self.allergens)
        try json.set(Keys.notes, self.notes)
        return json
    }

    convenience init(json: JSON) throws {
        self.init(title: try json.get(Keys.title),
                  studentPrice: try json.get(Keys.studentPrice),
                  employeePrice: try json.get(Keys.employeePrice),
                  image: try json.get(Keys.image),
                  canteen: try json.get(Keys.canteen),
                  detailURL: try json.get(Keys.detailURL),
                  type: try json.get(Keys.type),
                  counter: try json.get(Keys.counter),
                  ingredients: try json.get(Keys.ingredients),
                  additives: try json.get(Keys.additives),
                  allergens: try json.get(Keys.allergens),
                  notes: try json.get(Keys.notes))
    }
}

extension Meal: ResponseRepresentable { }
