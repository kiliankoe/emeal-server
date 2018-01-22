import Foundation

extension Meal {
    enum Information: String {
        case beef = "rindfleisch"
        case pork = "schweinefleisch"
        case alcohol = "alkohol"
        case garlic = "knoblauch"
        case vegetarian = "vegetarisch"
        case vegan = "vegan"
        case rennet = " lab" // '-mit tierischem lab-' & 'gorgonzola enthält tierisches lab'
        case nomeat = "kein fleisch"
        case red = "rot"
        case green = "grün"
        case blue = "blau"
        case mensavital = "mensavital"
        case labeled = "kennzeichnung an der theke"

        static var all: [Information] = [.beef, .pork, .alcohol, .garlic, .vegetarian, .vegan,
                                         .rennet, .nomeat, .red, .green, .blue, .mensavital,
                                         .labeled]

        init?(value: String) {
            let value = value.lowercased()
            for ing in Information.all {
                if value.contains(ing.rawValue) {
                    self = ing
                    return
                }
            }
            Log.error("⁉️ Unknown meal information '\(value)'.")
            return nil
        }

        var identifier: String {
            switch self {
            case .beef: return "beef"
            case .pork: return "pork"
            case .alcohol: return "alcohol"
            case .garlic: return "garlic"
            case .vegetarian: return "vegetarian"
            case .vegan: return "vegan"
            case .rennet: return "rennet"
            case .nomeat: return "no_meat"
            case .red: return "red"
            case .green: return "green"
            case .blue: return "blue"
            case .mensavital: return "mensavital"
            case .labeled: return "labeled"
            }
        }
    }
}
