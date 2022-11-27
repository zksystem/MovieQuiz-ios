//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Konstantin Zuykov on 27.11.2022.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func getQuestionsAmout() -> Int {
        questionsAmount
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
