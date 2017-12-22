import Foundation
import SwiftSoup

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

enum Week: Int {
    case current = 0
    case next
    case afterNext

    static let all: [Week] = [.current, .next, .afterNext]

    var dayOffsetToNow: Int {
        return 7 * self.rawValue
    }
}

enum Day: Int {
    case sunday = 0
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    func weekdayOffset(to date: Date) -> Int {
        let comp = Calendar(identifier: .gregorian).dateComponents([.weekday], from: date)
        let weekoffset = self == .sunday ? 7 : 0
        return (self.rawValue + 1) - (comp.weekday ?? 0) + weekoffset
    }

    static let all: [Day] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
}

func isodate(forDay day: Day, inWeek week: Week) -> ISODate {
    let offset = week.dayOffsetToNow + day.weekdayOffset(to: Date())
    let date = Date().addingTimeInterval(TimeInterval(offset * 24 * 3600))
    return date.dateStamp
}
