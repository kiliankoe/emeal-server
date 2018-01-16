import Foundation
import Vapor
import FluentProvider
import HTTP

typealias ISODate = String

final class Meal: Model {
    let storage = Storage()

    var title: String
    var canteen: String
    var date: ISODate

    var isSoldOut: Bool
    var counter: String?
    var isEveningOffer: Bool
    var studentPrice: Double?
    var employeePrice: Double?
    var image: String?
    let detailURL: URL
    var information: [String]
    var additives: [String]
    var allergens: [String]

    func update(from other: Meal) throws {
        self.title = other.title
        self.canteen = other.canteen
        self.date = other.date
        self.isSoldOut = other.isSoldOut
        self.counter = other.counter
        self.isEveningOffer = other.isEveningOffer
        if let studentPrice = other.studentPrice {
            self.studentPrice = studentPrice
        }
        if let employeePrice = other.employeePrice {
            self.employeePrice = employeePrice
        }
        if let image = other.image {
            self.image = image
        }
        if !other.information.isEmpty {
            self.information = other.information
        }
        if !other.additives.isEmpty {
            self.additives = other.additives
        }
        if !other.allergens.isEmpty {
            self.allergens = other.allergens
        }

        try self.save()
    }

    init(title: String,
         canteen: String,
         date: ISODate,
         isSoldOut: Bool,
         counter: String?,
         isEveningOffer: Bool,
         studentPrice: Double?,
         employeePrice: Double?,
         image: String?,
         detailURL: URL,
         information: [String],
         additives: [String],
         allergens: [String]) {
            self.title = title
            self.canteen = canteen
            self.date = date
            self.isSoldOut = isSoldOut
            self.counter = counter
            self.isEveningOffer = isEveningOffer
            self.studentPrice = studentPrice
            self.employeePrice = employeePrice
            self.image = image
            self.detailURL = detailURL
            self.information = information
            self.additives = additives
            self.allergens = allergens
    }

    enum Keys {
        static let title = "title"
        static let canteen = "canteen"
        static let date = "date"
        static let isSoldOut = "isSoldOut"
        static let counter = "counter"
        static let isEveningOffer = "isEveningOffer"
        static let studentPrice = "studentPrice"
        static let employeePrice = "employeePrice"
        static let image = "image"
        static let detailURL = "detailURL"
        static let information = "information"
        static let additives = "additives"
        static let allergens = "allergens"
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.title, self.title)
        try row.set(Keys.canteen, self.canteen)
        try row.set(Keys.date, self.date)
        try row.set(Keys.isSoldOut, self.isSoldOut)
        try row.set(Keys.counter, self.counter)
        try row.set(Keys.isEveningOffer, self.isEveningOffer)
        try row.set(Keys.studentPrice, self.studentPrice)
        try row.set(Keys.employeePrice, self.employeePrice)
        try row.set(Keys.image, self.image)
        try row.set(Keys.detailURL, self.detailURL.absoluteString)

        let information = self.information
        try row.set(Keys.information, information.semicolonStr)

        let additives = self.additives
        try row.set(Keys.additives, additives.semicolonStr)

        let allergens = self.allergens
        try row.set(Keys.allergens, allergens.semicolonStr)

        return row
    }

    init(row: Row) throws {
        self.title = try row.get(Keys.title)
        self.canteen = try row.get(Keys.canteen)
        self.date = try row.get(Keys.date)
        self.isSoldOut = try row.get(Keys.isSoldOut)
        self.counter = try row.get(Keys.counter)
        self.isEveningOffer = try row.get(Keys.isEveningOffer)
        self.studentPrice = try row.get(Keys.studentPrice)
        self.employeePrice = try row.get(Keys.employeePrice)
        self.image = try row.get(Keys.image)
        self.detailURL = try row.get(Keys.detailURL)

        let information: String = try row.get(Keys.information)
        self.information = information.semicolonArr

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
            builder.string(Keys.counter, optional: true)
            builder.bool(Keys.isEveningOffer)
            builder.double(Keys.studentPrice, optional: true)
            builder.double(Keys.employeePrice, optional: true)
            builder.string(Keys.image, optional: true)
            builder.string(Keys.detailURL)
            builder.string(Keys.information)
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
        try json.set(Keys.counter, self.counter)
        try json.set(Keys.isEveningOffer, self.isEveningOffer)
        try json.set(Keys.studentPrice, self.studentPrice)
        try json.set(Keys.employeePrice, self.employeePrice)
        try json.set(Keys.image, self.image)
        try json.set(Keys.detailURL, self.detailURL.absoluteString)
        try json.set(Keys.information, self.information)
        try json.set(Keys.additives, self.additives)
        try json.set(Keys.allergens, self.allergens)
        return json
    }

    convenience init(json: JSON) throws {
        self.init(title: try json.get(Keys.title),
                  canteen: try json.get(Keys.canteen),
                  date: try json.get(Keys.date),
                  isSoldOut: try json.get(Keys.isSoldOut),
                  counter: try json.get(Keys.counter),
                  isEveningOffer: try json.get(Keys.isEveningOffer),
                  studentPrice: try json.get(Keys.studentPrice),
                  employeePrice: try json.get(Keys.employeePrice),
                  image: try json.get(Keys.image),
                  detailURL: try json.get(Keys.detailURL),
                  information: try json.get(Keys.information),
                  additives: try json.get(Keys.additives),
                  allergens: try json.get(Keys.allergens))
    }
}

extension Meal: ResponseRepresentable { }
