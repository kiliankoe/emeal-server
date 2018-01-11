import Foundation
import SwiftSoup

enum Job {
    case menu(week: Week, day: Day)
    case meal(canteen: String, date: ISODate, url: URL)

    var date: ISODate {
        switch self {
        case let .menu(week: week, day: day):
            return isodate(forDay: day, inWeek: week)
        case let .meal(canteen: _, date: date, url: _):
            return date
        }
    }

    var url: URL {
        switch self {
        case let .menu(week: week, day: day):
            return MenuScraper.menuURL(forWeek: week, andDay: day)
        case let .meal(canteen: _, date: _, url: url):
            return url
        }
    }

    func fetchDocument() -> Document? {
        guard
            let content = Network.fetch(url: self.url),
            let document = try? SwiftSoup.parse(content)
        else {
            Log.error("Failed fetching/parsing resource: \(url)")
            return nil
        }

        return document
    }
}
