//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Konstantin Zuykov on 25.11.2022.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    let buttonsDelay: UInt32 = 1
    let alertDelay: UInt32 = 3
    
    let imageIde = "Poster"
    let indexLabelId = "Index"
    let yesButtonId = "Yes"
    let noButtonId = "No"
    
    let expectedIndexLabelChange = "2/10"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }

    func testYesButton() {
        let firstPoster = app.images[imageIde]
        
        app.buttons[yesButtonId].tap()
        
        let secondPoster = app.images[imageIde]
        let indexLabel = app.staticTexts[indexLabelId]
        
        sleep(buttonsDelay)
        
        XCTAssertTrue(indexLabel.label == expectedIndexLabelChange)
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testNoButton() {
        let firstPoster = app.images[imageIde]
        
        app.buttons[noButtonId].tap()
        
        let secondPoster = app.images[imageIde]
        let indexLabel = app.staticTexts[indexLabelId]
        
        sleep(buttonsDelay)
        
        XCTAssertTrue(indexLabel.label == expectedIndexLabelChange)
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testResultAlertShown() {
        let expectedAlertTitle = "Этот раунд окончен!"
        let expectedButtonLabel = "Сыграть ещё раз"
        
        for _ in 1...10 {
            app.buttons[yesButtonId].tap()
            sleep(buttonsDelay)
        }
        
        sleep(alertDelay)
        
        let alert = app.alerts[expectedAlertTitle]
        XCTAssertTrue(app.alerts[expectedAlertTitle].exists)
        XCTAssertTrue(alert.label == expectedAlertTitle)
        XCTAssertTrue(alert.buttons.firstMatch.label == expectedButtonLabel)
    }
    
}
