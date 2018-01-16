import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

class RouteTests: TestCase {
    let drop = try! Droplet.testable()

    override func setUp() {
        Testing.onFail = XCTFail

        let meal = Meal(title: "meal", canteen: "canteen", date: Date().dateStamp, isSoldOut: false, counter: "counter", isEveningOffer: false, studentPrice: 1.0, employeePrice: 2.0, image: nil, detailURL: URL(string: "https://example.com")!, information: [], additives: [], allergens: [])
        try! meal.save()
    }

    func testCanteens() throws {
        try drop
            .testResponse(to: .get, at: "canteens")
            .assertStatus(is: .ok)
            .assertBody(contains: "Alte Mensa")
    }

    func testMeals() throws {
        try drop
            .testResponse(to: .get, at: "meals")
            .assertStatus(is: .ok)
            .assertBody(contains: "meal")
    }

    func testSearch() throws {
        try drop
            .testResponse(to: .get, at: "search")
            .assertStatus(is: .badRequest)

//        try drop
//            .testResponse(to: .get, at: "search?query=meal")
//            .assertStatus(is: .ok)
    }

    func testUpdate() throws {
        try drop
            .testResponse(to: .post, at: "update", body: nil)
            .assertStatus(is: .unauthorized)
    }
}

extension RouteTests {
    static let allTests = [
        ("testCanteens", testCanteens),
        ("testMeals", testMeals),
        ("testSearch", testSearch),
        ("testUpdate", testUpdate),
    ]
}
