import Vapor
import FluentProvider
import HTTP

final class Canteen: Model {
    let storage = Storage()

    let name: String
    let city: String
    let address: String
    let latitude: Double
    let longitude: Double

    init(name: String, city: String, address: String, latitude: Double, longitude: Double) {
        self.name = name
        self.city = city
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }

    enum Keys {
        static let id = "id"
        static let name = "name"
        static let city = "city"
        static let address = "address"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, self.name)
        try row.set(Keys.city, self.city)
        try row.set(Keys.address, self.address)
        try row.set(Keys.latitude, self.latitude)
        try row.set(Keys.longitude, self.longitude)
        return row
    }

    init(row: Row) throws {
        self.name = try row.get(Keys.name)
        self.city = try row.get(Keys.city)
        self.address = try row.get(Keys.address)
        self.latitude = try row.get(Keys.latitude)
        self.longitude = try row.get(Keys.longitude)
    }
}

extension Canteen: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.name)
            builder.string(Keys.city)
            builder.string(Keys.address)
            builder.double(Keys.latitude)
            builder.double(Keys.longitude)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Canteen: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, self.id)
        try json.set(Keys.name, self.name)
        try json.set(Keys.city, self.city)
        try json.set(Keys.address, self.address)
        try json.set("coordinates", [Keys.latitude: self.latitude, Keys.longitude: self.longitude])
        return json
    }

    convenience init(json: JSON) throws {
        self.init(name: try json.get(Keys.name),
                  city: try json.get(Keys.city),
                  address: try json.get(Keys.address),
                  latitude: try json.get(Keys.latitude),
                  longitude: try json.get(Keys.longitude))
    }
}

extension Canteen: ResponseRepresentable { }
