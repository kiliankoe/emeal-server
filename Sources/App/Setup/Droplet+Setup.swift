@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
    }

    public func setupDummyMeals() throws {
        try [
            Meal(title: "🌯", canteen: "Alte Mensa", date: "2017-12-14", studentPrice: 1.0, employeePrice: 10.0, image: nil, detailURL: "none", ingredients: [], additives: [], allergens: [], notes: []),
            Meal(title: "🍕", canteen: "Mensa Reichenbachstraße", date: "2017-12-14", studentPrice: 1.0, employeePrice: 10.0, image: nil, detailURL: "none", ingredients: [], additives: [], allergens: [], notes: []),
            Meal(title: "🌮", canteen: "BioMensa U-Boot", date: "2017-12-15", studentPrice: 1.0, employeePrice: 10.0, image: nil, detailURL: "none", ingredients: [], additives: [], allergens: [], notes: []),
            Meal(title: "🍔", canteen: "Zeltschlößchen", date: "2017-12-15", studentPrice: 1.0, employeePrice: 10.0, image: nil, detailURL: "none", ingredients: [], additives: [], allergens: [], notes: []),
        ].forEach { try $0.save() }
    }
}
