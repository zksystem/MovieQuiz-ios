//
//  MovieQuizPresenterTest.swift
//  MovieQuizTests
//
//  Created by Konstantin Zuykov on 27.11.2022.
//

import XCTest

@testable import MovieQuiz

// MARK: Tests

class MovieQuizPresenterTest: XCTestCase {
    
    let presenter = MovieQuizPresenter(viewController: MovieQuizViewControllerProtocolMock())
    
    func testSConverter() throws {

        presenter.resetQuestionIndex()
        
        let srcData = Data(capacity: 0xff)
        let srcImage = UIImage(data: srcData) ?? UIImage()
        let srcText = "Sample text"
        let srcIndexText = "1/10"
        let srcCorrect = true
        
        let question = QuizQuestion(image: srcData, text: srcText, correctAnswer: srcCorrect)
        let target = presenter.convert(model: question)

        XCTAssertEqual(srcImage, target.image)
        XCTAssertEqual(srcText, target.question)
        XCTAssertEqual(srcIndexText, target.questionNumber)
        
        
    }
    
}
