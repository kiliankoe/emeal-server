import Foundation
import SwiftSoup

final class MenuScraper {
    static func menuURL(forWeek week: Week, andDay day: Day) -> URL {
        return URL(string: "https://www.studentenwerk-dresden.de/mensen/speiseplan/w\(week.rawValue)-d\(day.stuweValue).html")!
    }

    static func extractMenus(from doc: Document) -> Elements? {
        return try? doc.getElementsByClass("speiseplan")
    }

    static func parseMenu(_ menu: Element) -> (canteen: String, meals: [String]) {
        let rows = try? menu.select("tr")
        let canteen = ((try? rows?.first()?.select("th").first()?.text() ?? "") ?? "")
            .replacingOccurrences(of: "Angebote ", with: "")
            .replacingOccurrences(of: " (Bio-Code-Nummer: DE-ÖKO-021)", with: "") // yay for edgecases

        let meals = (try? rows?
            .dropFirst()
            .map { try $0.select("a").first()?.attr("href") ?? "" }
            .filter { !$0.isEmpty }
            .filter { $0 != "#" }
            .map { "https://www.studentenwerk-dresden.de/mensen/speiseplan/\($0)" }
            ?? []) ?? []

        return (canteen, meals)
    }

    static func extractCanteensAndMeals(from doc: Document) -> [(canteen: String, meals: [String])] {
        return MenuScraper.extractMenus(from: doc)?
            .map(MenuScraper.parseMenu)
            ?? []
    }
}
