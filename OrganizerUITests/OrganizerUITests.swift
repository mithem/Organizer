//
//  OrganizerUITests.swift
//  OrganizerUITests
//
//  Created by Miguel Themann on 26.09.20.
//

import XCTest

class OrganizerUITests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//
//        // In UI tests it is usually best to stop immediately when a failure occurs.
//        continueAfterFailure = false
//
//        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // UI tests must launch the application that they test.
//        let app = XCUIApplication()
//        app.launch()
//
//        // Use recording to get started writing UI tests.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
    
    func testExample() throws {
        let app = XCUIApplication()
        UIPasteboard.general.string = "hello world!\n- [] 7min hello there!"
        app.launch()
        
        let tablesQuery = XCUIApplication().tables
        
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Parse from clipboard/pasteboard"]/*[[".cells[\"Parse from clipboard\/pasteboard\"].buttons[\"Parse from clipboard\/pasteboard\"]",".buttons[\"Parse from clipboard\/pasteboard\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        XCTAssertTrue(tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Exported 1 events."]/*[[".cells[\"Progress, Exported 1 events.\"].staticTexts[\"Exported 1 events.\"]",".staticTexts[\"Exported 1 events.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        XCTAssertEqual(tablesQuery.progressIndicators["ProgressBar"].value as? String, "100%")
    }
}
