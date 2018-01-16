import XCTest
import Foundation
import SwiftSoup
@testable import App

class MealDetailScraperTests: XCTestCase {
    var document1 = try! SwiftSoup.parse(mealDetailSource1)
    var document2 = try! SwiftSoup.parse(mealDetailSource2)

    func testExtractMealTitle() {
        let title1 = MealDetailScraper.extractTitle(from: document1)
        XCTAssertEqual(title1, "Karotten-Sesamschnitzel mit Püree von Roten Linsen mit Tomate, Rosine, Minze und Ingwer, dazu Blumenkohlsalat")
        let title2 = MealDetailScraper.extractTitle(from: document2)
        XCTAssertEqual(title2, "Burger mit Kassler, Malzbierzwiebeln, Pflaumen-Senf-Mayo und Gouda, dazu Salat")
    }

    func testExtractPrices() {
        let price1 = MealDetailScraper.extractPrices(from: document1)
        XCTAssertNil(price1.students)
        XCTAssertNil(price1.employees)
        let price2 = MealDetailScraper.extractPrices(from: document2)
        XCTAssertEqual(price2.students!, 2.5, accuracy: 0.01)
        XCTAssertEqual(price2.employees!, 4.2, accuracy: 0.01)
    }

    func testExtractImageURL() {
        let imgURL1 = MealDetailScraper.extractImageURL(from: document1)
        XCTAssertEqual(imgURL1, "https://bilderspeiseplan.studentenwerk-dresden.de/m18/201712/196257.jpg?date=201712181137")
        let imgURL2 = MealDetailScraper.extractImageURL(from: document2)
        XCTAssertNil(imgURL2)
    }

    func testExtractHeadlineInfo() {
        let (canteen1, counter1, evening1) = MealDetailScraper.extractHeadlineInfo(from: document1)!
        XCTAssertEqual(canteen1, "Alte Mensa")
        XCTAssertEqual(counter1, "fertig 3")
        XCTAssertFalse(evening1)

        let (canteen2, counter2, evening2) = MealDetailScraper.extractHeadlineInfo(from: document2)!
        XCTAssertEqual(canteen2, "Mensa Reichenbachstraße")
        XCTAssertEqual(counter2, "fertig 2")
        XCTAssertTrue(evening2)
    }

    func testExtractIngredients() {
        let ingredients1 = MealDetailScraper.extractInformation(from: document1)
        XCTAssertEqual(ingredients1, ["vegetarian", "garlic"])
        let ingredients2 = MealDetailScraper.extractInformation(from: document2)
        XCTAssertEqual(ingredients2, ["pork"])
    }

    func testExtractAdditives() {
        let additives1 = MealDetailScraper.extractAdditives(from: document1)
        XCTAssertEqual(additives1, [])
        let additives2 = MealDetailScraper.extractAdditives(from: document2)
        XCTAssertEqual(additives2, ["1", "2", "3", "5", "8"])
    }

    func testExtractAllergens() {
        let allergens1 = MealDetailScraper.extractAllergens(from: document1)
        XCTAssertEqual(allergens1, ["A", "A1", "C", "I", "K"])
        let allergens2 = MealDetailScraper.extractAllergens(from: document2)
        XCTAssertEqual(allergens2, ["A", "A1", "A2", "A3", "C", "G", "I", "J", "K", "L"])
    }

    func testScrapeAll() {
        let meal1 = MealDetailScraper.scrape(document: document1, url: URL(string: "https://example.com")!, forDate: Date())
        XCTAssertNotNil(meal1)

        let meal2 = MealDetailScraper.scrape(document: document1, url: URL(string: "https://example.com")!, forDate: Date())
        XCTAssertNotNil(meal2)
    }
}

extension MealDetailScraperTests {
    static let allTests = [
        ("testExtractMealTitle", testExtractMealTitle),
        ("testExtractPrices", testExtractPrices),
        ("testExtractImageURL", testExtractImageURL),
        ("testExtractHeadlineInfo", testExtractHeadlineInfo),
        ("testExtractIngredients", testExtractIngredients),
        ("testExtractAdditives", testExtractAdditives),
        ("testExtractAllergens", testExtractAllergens),
    ]
}
