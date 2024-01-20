//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Артур  Арсланов on 20.01.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    var correctAnswers = 0

    
    init(viewController: MovieQuizViewController){
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.activityIndicator.startAnimating()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let question = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return question
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
//            self?.viewController?.activityIndicator.stopAnimating()
        }
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            viewController?.showAlert()
            viewController?.chooseIsEnableButtons(true)
        } else {
            viewController?.chooseIsEnableButtons(true)
            switchToNextQuestion()
            viewController?.activityIndicator.startAnimating()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultMessage() -> String {
        var resultMessage = ""
        if let statisticService = statisticService {
            
            let bestGame = statisticService.bestGame
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            resultMessage = """
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Ваш результат: \(correctAnswers)\\\(questionsAmount)
                Рекорд: \(bestGame.correct)\\\(questionsAmount) (\(bestGame.date.dateTimeString))
                Средняя точность: \(accuracy)%
            """
        }
        return resultMessage
        
    }
    
    func yesButtonPressed() {
        didAnswer(isYes: true)
    }
    
    func noButtonPressed() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) -> Bool {
        if isCorrectAnswer {
            correctAnswers += 1
            return true
        }
        return false
    }
    
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
