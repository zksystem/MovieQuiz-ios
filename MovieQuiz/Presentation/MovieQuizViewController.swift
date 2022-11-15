//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Konstantin Zuykov on 07.11.2022.
//

import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
        
        yesButtonOutlet.isEnabled = true
        noButtonOutlet.isEnabled = true
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var noButtonOutlet: UIButton!
    @IBOutlet weak var yesButtonOutlet: UIButton!
    
    //MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        yesButtonOutlet.isEnabled = false
        showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        noButtonOutlet.isEnabled = false
        showAnswerResult(isCorrect: false == currentQuestion.correctAnswer)
    }
    
    // MARK: - Delegates
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private function
    
    private func getAppColor(_ name: String) -> CGColor {
        if let color = UIColor(named: name) {
            return color.cgColor
        } else {
            return UIColor.white.cgColor
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? getAppColor("ypGreen") : getAppColor("ypRed")
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        let completion = {
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: completion)
        
        let alertPsenenter = AlertPresenter(alertModel: alertModel, viewController: self)
        alertPsenenter.showResultsAlert()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // All questions are shown
            if let statisticService = statisticService {
                // store current play result
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                
                let bestGame = statisticService.bestGame
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.YYYY HH:mm"
                
                let text = "Ваш результат: \(correctAnswers) из 10\n" +
                "Количество сыграных квизов: \(statisticService.gamesCount)\n" +
                "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateFormatter.string(from: bestGame.date)))\n" +
                "Средняя точность: (\(String(format: "%.2f", statisticService.totalAccuracy))%)\n"
                
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                show(quiz: viewModel)
            }
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        yesButtonOutlet.isEnabled = true
        noButtonOutlet.isEnabled = true
    }
    
}
