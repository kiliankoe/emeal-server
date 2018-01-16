import XCTest
import Foundation
import SwiftSoup
@testable import App

class MenuScraperTests: XCTestCase {
    var document1 = try! SwiftSoup.parse(menuSource1)

    func testExtractMenus() {
        let menus = MenuScraper.extractMenus(from: document1)!
            .map(MenuScraper.parseMenu)

        XCTAssertEqual(menus[1]!.canteen, "Mensa Reichenbachstraße")
        XCTAssertEqual(menus[4]!.canteen, "Alte Mensa")

        XCTAssertEqual(menus[1]!.meals[0].absoluteString, "https://www.studentenwerk-dresden.de/mensen/speiseplan/details-197311.html")
        XCTAssertEqual(menus[1]!.meals.count, 7)
        XCTAssertEqual(menus[4]!.meals.count, 0)
    }

    func testMenuURL() {
        XCTAssertEqual(
            MenuScraper.menuURL(forWeek: .current, andDay: .monday, today: .monday).absoluteString,
            "https://www.studentenwerk-dresden.de/mensen/speiseplan/w0-d1.html")
        XCTAssertEqual(
            MenuScraper.menuURL(forWeek: .next, andDay: .wednesday, today: .tuesday).absoluteString,
            "https://www.studentenwerk-dresden.de/mensen/speiseplan/w1-d3.html")
        XCTAssertEqual(
            MenuScraper.menuURL(forWeek: .afterNext, andDay: .sunday, today: .saturday).absoluteString,
            "https://www.studentenwerk-dresden.de/mensen/speiseplan/w2-d0.html")
        XCTAssertEqual(
            MenuScraper.menuURL(forWeek: .next, andDay: .sunday, today: .sunday).absoluteString,
            "https://www.studentenwerk-dresden.de/mensen/speiseplan/w0-d0.html")
    }

    func testExtractDate() {
        XCTAssertEqual(
            MenuScraper.extractDate(from: document1)?.dateStamp,
            "2017-12-21")
    }

    func testExtractCanteensAndMeals() {
        let menus = MenuScraper.extractCanteensAndMeals(from: document1)
        XCTAssertEqual(menus.count, 19)
    }
}

extension MenuScraperTests {
    static let allTests = [
        ("testExtractMenus", testExtractMenus),
        ("testMenuURL", testMenuURL),
        ("testExtractDate", testExtractDate),
        ("testExtractCanteensAndMeals", testExtractCanteensAndMeals),
    ]
}
