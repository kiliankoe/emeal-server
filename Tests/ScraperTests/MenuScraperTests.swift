import XCTest
import Foundation
import SwiftSoup
@testable import App

class MenuScraperTests: XCTestCase {
    var document1: Document!

    override func setUp() {
        self.document1 = try! SwiftSoup.parse(menuSource1)
    }

    func testExtractMenus() {
        let menus = MenuScraper.extractMenus(from: document1)!
            .map(MenuScraper.parseMenu)

        XCTAssertEqual(menus[1].canteen, "Mensa Reichenbachstraße")
        XCTAssertEqual(menus[4].canteen, "Alte Mensa")

        XCTAssertEqual(menus[1].meals[0], "https://www.studentenwerk-dresden.de/mensen/speiseplan/details-197311.html?pni=1")
        XCTAssertEqual(menus[1].meals.count, 7)
        XCTAssertEqual(menus[4].meals.count, 0)
    }

}

extension MenuScraperTests {
    static let allTests = [
        ("testExtractMenus", testExtractMenus),
    ]
}
