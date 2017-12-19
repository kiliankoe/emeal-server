import XCTest
import Foundation
import SwiftSoup
@testable import App

class MealDetailScraperTests: XCTestCase {
    var document1: Document!
    var document2: Document!
    var scraper: MealDetailScraper!

    override func setUp() {
        self.document1 = try! SwiftSoup.parse(mealDetailSource1)
        self.document2 = try! SwiftSoup.parse(mealDetailSource2)
        self.scraper = MealDetailScraper()
    }

    func testExtractMealTitle() {
        let title1 = scraper.extractTitle(from: document1)
        XCTAssertEqual(title1, "Karotten-Sesamschnitzel mit Püree von Roten Linsen mit Tomate, Rosine, Minze und Ingwer, dazu Blumenkohlsalat")
        let title2 = scraper.extractTitle(from: document2)
        XCTAssertEqual(title2, "Burger mit Kassler, Malzbierzwiebeln, Pflaumen-Senf-Mayo und Gouda, dazu Salat")
    }

    func testExtractPrices() {
        let price1 = scraper.extractPrices(from: document1)
        XCTAssertEqual(price1.students!, 2.1, accuracy: 0.01)
        XCTAssertEqual(price1.employees!, 3.8, accuracy: 0.01)
        let price2 = scraper.extractPrices(from: document2)
        XCTAssertEqual(price2.students!, 2.5, accuracy: 0.01)
        XCTAssertEqual(price2.employees!, 4.2, accuracy: 0.01)
    }

    func testExtractImageURL() {
        let imgURL1 = scraper.extractImageURL(from: document1)
        XCTAssertEqual(imgURL1, "https://bilderspeiseplan.studentenwerk-dresden.de/m18/201712/196257.jpg?date=201712181137")
        let imgURL2 = scraper.extractImageURL(from: document2)
        XCTAssertEqual(imgURL2, "")
    }

    func testExtractIngredients() {
        let ingredients1 = scraper.extractIngredients(from: document1)
        XCTAssertEqual(ingredients1, ["Menü ist vegetarisch", "enthält Knoblauch"])
        let ingredients2 = scraper.extractIngredients(from: document2)
        XCTAssertEqual(ingredients2, ["enthält Schweinefleisch"])
    }

    func testExtractAdditives() {
        let additives1 = scraper.extractAdditives(from: document1)
        XCTAssertEqual(additives1, [])
        let additives2 = scraper.extractAdditives(from: document2)
        XCTAssertEqual(additives2, ["mit Farbstoff (1)", "mit Konservierungsstoff (2)", "mit Antioxydationsmittel (3)", "geschwefelt (5)", "mit Phosphat (8)"])
    }

    func testExtractAllergens() {
        let allergens1 = scraper.extractAllergens(from: document1)
        XCTAssertEqual(allergens1, ["Glutenhaltiges Getreide (A)", "Weizen (A1)", "Eier (C)", "Sellerie (I)", "Sesam (K)"])
        let allergens2 = scraper.extractAllergens(from: document2)
        XCTAssertEqual(allergens2, ["Glutenhaltiges Getreide (A)", "Weizen (A1)", "Roggen (A2)", "Gerste (A3)", "Eier (C)", "Milch/Milchzucker (Laktose) (G)", "Sellerie (I)", "Senf (J)", "Sesam (K)", "Sulfit/Schwefeldioxid (L)"])
    }
}

extension MealDetailScraperTests {
    static let allTests = [
        ("testExtractMealTitle", testExtractMealTitle),
        ("testExtractPrices", testExtractPrices),
        ("testExtractImageURL", testExtractImageURL),
        ("testExtractIngredients", testExtractIngredients),
        ("testExtractAdditives", testExtractAdditives),
        ("testExtractAllergens", testExtractAllergens),
    ]
}
