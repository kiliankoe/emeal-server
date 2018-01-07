import XCTest
import Foundation
@testable import App

class WeekDayTests: XCTestCase {
    func testWeekOffset() {
        XCTAssertEqual(Week.current.dayOffsetToNow, 0)
        XCTAssertEqual(Week.next.dayOffsetToNow, 7)
        XCTAssertEqual(Week.afterNext.dayOffsetToNow, 14)
    }

    func testDayToday() {
        let sunday = Date(timeIntervalSince1970: 1515332286)
        XCTAssertEqual(Day.today(from: sunday), .sunday)
        let monday = Date(timeIntervalSince1970: 1515418686)
        XCTAssertEqual(Day.today(from: monday), .monday)
        let wednesday = Date(timeIntervalSince1970: 1515591486)
        XCTAssertEqual(Day.today(from: wednesday), .wednesday)
        let saturday = Date(timeIntervalSince1970: 1510407486)
        XCTAssertEqual(Day.today(from: saturday), .saturday)
    }

    func testISODate() {
        let sunday_2018_01_07 = Date(timeIntervalSince1970: 1515332286)
        XCTAssertEqual(isodate(forDay: .sunday, inWeek: .current, fromDate: sunday_2018_01_07), "2018-01-07")
        XCTAssertEqual(isodate(forDay: .saturday, inWeek: .current, fromDate: sunday_2018_01_07), "2018-01-06")
        XCTAssertEqual(isodate(forDay: .monday, inWeek: .next, fromDate: sunday_2018_01_07), "2018-01-08")

        let tuesday_2018_01_09 = Date(timeIntervalSince1970: 1515505086)
        XCTAssertEqual(isodate(forDay: .sunday, inWeek: .current, fromDate: tuesday_2018_01_09), "2018-01-14")
        XCTAssertEqual(isodate(forDay: .monday, inWeek: .current, fromDate: tuesday_2018_01_09), "2018-01-08")
        XCTAssertEqual(isodate(forDay: .sunday, inWeek: .next, fromDate: tuesday_2018_01_09), "2018-01-21")
        XCTAssertEqual(isodate(forDay: .tuesday, inWeek: .afterNext, fromDate: tuesday_2018_01_09), "2018-01-23")
    }
}

extension WeekDayTests {
    static let allTests = [
        ("testWeekOffset", testWeekOffset),
        ("testDayToday", testDayToday),
        ("testISODate", testISODate),
    ]
}
