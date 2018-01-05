#if os(Linux)

import XCTest
// @testable import AppTests
@testable import ScraperTests

XCTMain([
    // AppTests
    // testCase(PostControllerTests.allTests),
    // testCase(RouteTests.allTests)
    testCase(MenuScraperTests.allTests),
    testCase(MealDetailScraperTests.allTests),
])

#endif
