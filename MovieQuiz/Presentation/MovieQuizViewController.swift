//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Konstantin Zuykov on 07.11.2022.
//

import UIKit

final class MovieQuizViewController: UIViewController {
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    private var presenter: MovieQuizPresenter!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter()
        statisticService = StatisticServiceImplementation()
        
        presenter = MovieQuizPresenter(viewController: self)
        presenter.resetQuestionIndex()
        presenter.restartGame()
        
        yesButtonOutlet.isEnabled = true
        noButtonOutlet.isEnabled = true
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var noButtonOutlet: UIButton!
    @IBOutlet weak var yesButtonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        yesButtonOutlet.isEnabled = false
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        noButtonOutlet.isEnabled = false
        presenter.noButtonClicked()
    }
    
    // MARK: - Alerts
    
    func showEndGameAlert() {
        if let statisticService = statisticService {
            let correctAnswers = presenter.getCorrectAnswers()
            // store current play result
            statisticService.store(correct: correctAnswers, total: presenter.getQuestionsAmout())
            
            // show alert message
            let bestGame = statisticService.bestGame
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.YYYY HH:mm"
            
            let alertTitle = "Этот раунд окончен!"
            let alertButtonText = "Сыграть ещё раз"
            let alertText = """
            Ваш результат: \(correctAnswers) из 10
            Количество сыграных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateFormatter.string(from: bestGame.date)))
            Средняя точность: (\(String(format: "%.2f", statisticService.totalAccuracy))%)
            """
            let resultsAlertModel = AlertModel(title: alertTitle, message: alertText, buttonText: alertButtonText) { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
            alertPresenter?.show(controller: self, model: resultsAlertModel)
        }
    }
    
    func showNetworkErrorAlert(message: String) {
        hideLoadingIndicator()
        let errorAlertModel = AlertModel(title: "Ошибка",
                                         message: message,
                                         buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        
        alertPresenter?.show(controller: self, model: errorAlertModel)
    }
    
    
    // MARK: - functions
    
    private func getAppColor(_ name: String) -> CGColor {
        if let color = UIColor(named: name) {
            return color.cgColor
        } else {
            return UIColor.white.cgColor
        }
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? getAppColor("ypGreen") : getAppColor("ypRed")
        
        if isCorrect {
            presenter.incCorrectAnswers()
        }
        
        showLoadingIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presenter?.showNextQuestionOrResults()
            self.hideLoadingIndicator()
            self.yesButtonOutlet.isEnabled = true
            self.noButtonOutlet.isEnabled = true
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
    }
    
    
}
