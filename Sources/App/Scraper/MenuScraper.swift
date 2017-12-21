import Foundation
import SwiftSoup

enum Week: Int {
    case current = 0
    case next
    case afterNext

    static let all: [Week] = [.current, .next, .afterNext]
}

enum Day: Int {
    case sunday = 0
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    static let all: [Day] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
}

final class MenuScraper {
    static func menuURL(forWeek week: Week, andDay day: Day) -> URL {
        return URL(string: "https://www.studentenwerk-dresden.de/mensen/speiseplan/w\(week.rawValue)-d\(day.rawValue).html")!
    }

    static func extractMenus(from doc: Document) -> Elements? {
        return try? doc.getElementsByClass("speiseplan")
    }

    static func parseMenu(_ menu: Element) -> (canteen: String, meals: [String]) {
        let rows = try? menu.select("tr")
        let canteen = ((try? rows?.first()?.select("th").first()?.text() ?? "") ?? "").replacingOccurrences(of: "Angebote ", with: "")

        let meals = (try? rows?
            .dropFirst()
            .map { try $0.select("a").first()?.attr("href") ?? "" }
            .filter { !$0.isEmpty }
            .map { "https://www.studentenwerk-dresden.de/mensen/speiseplan/\($0)" }
            ?? []) ?? []

        return (canteen, meals)
    }

    
}
