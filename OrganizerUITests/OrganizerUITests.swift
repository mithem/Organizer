//
//  OrganizerUITests.swift
//  OrganizerUITests
//
//  Created by Miguel Themann on 26.09.20.
//

import XCTest

class OrganizerUITests: XCTestCase {
    func testExample() throws {
        let app = XCUIApplication()
        UIPasteboard.general.string = "hello world!\n- [] 2min hello there!"
        app.launch()
        
        let tablesQuery = XCUIApplication().tables
        
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Parse from clipboard/pasteboard"]/*[[".cells[\"Parse from clipboard\/pasteboard\"].buttons[\"Parse from clipboard\/pasteboard\"]",".buttons[\"Parse from clipboard\/pasteboard\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let sheetsQuery = app.windows["SceneWindow"].sheets
        
        sheetsQuery/*@START_MENU_TOKEN@*/.windows.tables.buttons["Next"]/*[[".groups.windows.tables",".cells[\"Next\"].buttons[\"Next\"]",".buttons[\"Next\"]",".windows.tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.click()
        XCTAssertTrue(tablesQuery.staticTexts["The following events were exported."].exists)
        sheetsQuery/*@START_MENU_TOKEN@*/.windows.tables.buttons["Finish"]/*[[".groups.windows.tables",".cells[\"Finish\"].buttons[\"Finish\"]",".buttons[\"Finish\"]",".windows.tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        XCTAssertTrue((tablesQuery.progressIndicators["ProgressBar"].value as? String ?? "").starts(with: "100"))
    }
}
