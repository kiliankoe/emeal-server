import Foundation
import SwiftSoup

final class MenuScraper {
    static func menuURL(forWeek week: Week, andDay day: Day) -> URL {
        var weekVal = week.rawValue
        if day == .sunday && Day.today == .sunday {
            // There appears to be a bug in the Studentenwerk's server code, where the URL scheme
            // breaks on sundays. Specifically 'w0-d0' does not reference the current week's sunday
            // when being accessed on a sunday, but the next one. This might be intended behavior,
            // seeing how their week starts on sunday, but it makes it impossible to get the current
            // day's meals using the URL scheme below when being run on a sunday.
            // That's why this workaround exists ✌️
            weekVal -= 1
            // And yes, oddly enough this does seem to work with 0 - 1 = -1.
        }
        return URL(string: "https://www.studentenwerk-dresden.de/mensen/speiseplan/w\(weekVal)-d\(day.stuweValue).html")!
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
