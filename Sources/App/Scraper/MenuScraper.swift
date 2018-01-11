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

    static func parseMenu(_ menu: Element) -> (canteen: String, meals: [URL])? {
        do {
            let rows = try menu.select("tr")
            let canteen = (try rows.first()?.select("th").first()?.text() ?? "")
                .replacingOccurrences(of: "Angebote ", with: "")
                .replacingOccurrences(of: " (Bio-Code-Nummer: DE-ÖKO-021)", with: "") // yay for edgecases

            let mealRows = try rows.dropFirst() // row header
                .map { try $0.select("a").filter({ try
                    // .contains("details") is a workaround for skipping mensavital.de links
                    $0.attr("href").contains("details") }).first?.attr("href") ?? "" }
                .filter { !$0.isEmpty && $0 != "#" }

            let mealURLs = mealRows
                .flatMap { detailStr in
                    let details = detailStr.split(separator: "?").first ?? ""
                    guard details.hasPrefix("details") && details.hasSuffix(".html") else {
                        Log.error("")
                        return nil
                    }
                    return String(details)
                }
                .flatMap { detail -> URL? in
                    guard let url = URL(string: "https://www.studentenwerk-dresden.de/mensen/speiseplan/\(detail)") else {
                        Log.error("Malformed meal URL for '\(detail)'.")
                        return nil
                    }
                    return url
                }

            return (canteen, mealURLs)
        } catch let error {
            Log.error("Menu parse error: \(error)")
            return nil
        }
    }

    static func extractCanteensAndMeals(from doc: Document) -> [(canteen: String, meals: [URL])] {
        return MenuScraper.extractMenus(from: doc)?
            .flatMap(MenuScraper.parseMenu)
            ?? []
    }
}
