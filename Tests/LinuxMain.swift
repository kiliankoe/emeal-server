#if os(Linux)

import XCTest
@testable import AppTests
@testable import ScraperTests

XCTMain([
    // AppTests
    testCase(WeekDayTests.allTests),
    testCase(RouteTests.allTests),

    // ScraperTests
    testCase(MenuScraperTests.allTests),
    testCase(MealDetailScraperTests.allTests),
])

#endif
