import FluentProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
        preparations.append(Canteen.self)
        preparations.append(Meal.self)
        preparations.append(Menu.self)
    }

    // This is called after the db for canteens has been setup
    public func loadCanteens() throws {
        let all = self["canteen", "canteens"]?.array ?? []
        for c in all {
            try Canteen(name: try c.get(Canteen.Keys.name),
                        city: try c.get(Canteen.Keys.city),
                        address: try c.get(Canteen.Keys.address),
                        latitude: try c.get(Canteen.Keys.latitude),
                        longitude: try c.get(Canteen.Keys.longitude))
                .save()
        }
    }
}
