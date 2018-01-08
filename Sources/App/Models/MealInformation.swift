import Foundation

extension Meal {
    enum Information: String {
        case beef = "rindfleisch"
        case pork = "schweinefleisch"
        case alcohol = "alkohol"
        case garlic = "knoblauch"
        case vegetarian = "vegetarisch"
        case vegan = "vegan"
        case rennet = "tierischem lab"
        case nomeat = "kein fleisch"
        case red = "rot"
        case green = "grün"
        case blue = "blau"

        static var all: [Information] = [.beef, .pork, .alcohol, .garlic, .vegetarian, .vegan,
                                         .rennet, .nomeat, .red, .green, .blue]

        init?(value: String) {
            let value = value.lowercased()
            for ing in Information.all {
                if value.contains(ing.rawValue) {
                    self = ing
                    return
                }
            }
            print("⁉️ Unknown meal information '\(value)' Please add this to `Meal.Information` in MealInformation.swift.")
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
            }
        }
    }

    /// see https://www.studentenwerk-dresden.de/mensen/zusatzstoffe.html
    enum Additive: String {
        case dye = "(1)" // mit Farbstoff
        case preservative = "(2)" // mit Konservierungsstoffen
        case antioxidant = "(3)" // mit Antioxydationsmittel
        case flavorenhancer = "(4)" // mit Geschmacksverstärker
        case sulfurated = "(5)" // geschwefelt
        case blackened = "(6)" // geschwärzt
        case waxed = "(7)" // gewachst
        case phosphate = "(8)" // mit Phosphat
        case sweetener = "(9)" // mit Süßungsmittel
        case phenylalanine = "(10)" // enthält eine Phenylalaninquelle

        static var all: [Additive] = [.dye, .preservative, .antioxidant, .flavorenhancer, .sulfurated,
                                      .blackened, .waxed, .phosphate, .sweetener, .phenylalanine]

        init?(value: String) {
            let value = value.lowercased()
            for add in Additive.all {
                if value.contains(add.rawValue) {
                    self = add
                    return
                }
            }
            print("⁉️ Unknown meal additive '\(value)' Please add this to `Meal.Additive` in MealInformation.swift.")
            return nil
        }

        var identifier: String {
            switch self {
            case .dye: return "1"
            case .preservative: return "2"
            case .antioxidant: return "3"
            case .flavorenhancer: return "4"
            case .sulfurated: return "5"
            case .blackened: return "6"
            case .waxed: return "7"
            case .phosphate: return "8"
            case .sweetener: return "9"
            case .phenylalanine: return "10"
            }
        }
    }

    /// see https://www.studentenwerk-dresden.de/mensen/faq-8.html
    /// unfortunately not all possible allergens are listed there :/
    enum Allergen: String {
        case a = "(a)" // Glutenhaltiges Getreide
        case a1 = "(a1)" // Weizen
        case a2 = "(a2)" // Roggen
        case a3 = "(a3)" // Gerste
        case a4 = "(a4)" // Hafer
        case a5 = "(a5)" // Dinkel
        case a6 = "(a6)" // Grünkern
        case b = "(b)" // Krebstiere
        case c = "(c)" // Eier
        case d = "(d)" // Fisch
        case e = "(e)" // Erdnüsse
        case f = "(f)" // Soja
        case g = "(g)" // Milch/Milchzucker (Laktose)
        case h = "(h)" // Schalenfrüchte (Nüsse)
        case h1 = "(h1)" // Mandeln
        case h2 = "(h2)" // Haselnüsse
        case h3 = "(h3)" // Walnüsse
        case h4 = "(h4)" // Cashewnüsse
        case i = "(i)" // Sellerie
        case j = "(j)" // Senf
        case k = "(k)" // Sesam
        case l = "(l)" // Sulfit/Schwefeldioxid
        case m = "(m)" // Lupine
        case n = "(n)" // Weichtiere

        static var all: [Allergen] = [.a, .a1, .a2, .a3, .a4, .a5, .a6, .b, .c, .d, .e, .f, .g, .h,
                                      .h1, .h2, .h3, .h4, .i, .j, .k, .l, .m, .n]

        init?(value: String) {
            let value = value.lowercased()
            for all in Allergen.all {
                if value.contains(all.rawValue) {
                    self = all
                    return
                }
            }
            print("⁉️ Unknown meal allergen '\(value)' Please add this to `Meal.Allergen` in MealInformation.swift.")
            return nil
        }

        var identifier: String {
            switch self {
            case .a: return "A"
            case .a1: return "A1"
            case .a2: return "A2"
            case .a3: return "A3"
            case .a4: return "A4"
            case .a5: return "A5"
            case .a6: return "A6"
            case .b: return "B"
            case .c: return "C"
            case .d: return "D"
            case .e: return "E"
            case .f: return "F"
            case .g: return "G"
            case .h: return "H"
            case .h1: return "H1"
            case .h2: return "H2"
            case .h3: return "H3"
            case .h4: return "H4"
            case .i: return "I"
            case .j: return "J"
            case .k: return "K"
            case .l: return "L"
            case .m: return "M"
            case .n: return "N"
            }
        }
    }
}
