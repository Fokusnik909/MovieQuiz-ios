import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let alertPresenter = AlertPresenter()
    private var statisticService: StatisticService?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
        activityIndicator.hidesWhenStopped = true
        presenter = MovieQuizPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        
    }
    
    
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
    }
    
    @IBAction private func noButtonPressed(_ sender: Any) {
        chooseIsEnableButtons(false)
        presenter.noButtonPressed()
    }
    
    @IBAction private func yesButtonPressed(_ sender: Any) {
        chooseIsEnableButtons(false)
        presenter.yesButtonPressed()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if presenter.didAnswer(isCorrectAnswer: isCorrect) {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showAlert()
            chooseIsEnableButtons(true)
        } else {
            chooseIsEnableButtons(true)
            presenter.switchToNextQuestion()
            activityIndicator.startAnimating()
            presenter.questionFactory?.requestNextQuestion()
        }
    }
    
    private func settingUI() {
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        imageView.layer.cornerRadius = 20
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        activityIndicator.color = .white
    }
    
    func hideLoadingIndicator() {
            activityIndicator.isHidden = true
        }
    
    func showAlert() {
        guard (statisticService?.bestGame) != nil else {
            assertionFailure("error message")
            return
        }
        
        let alert = AlertModel(
            title: "Раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть ещё раз",
            completion: {[weak self] in
                guard let self = self else {return}
                self.presenter.resetGame()
                self.presenter.resetGame()
            }
        )
        alertPresenter.showAlert(model: alert, from: self)
    }
    
    private func makeResultMessage() -> String {
        var resultMessage = ""
        if let statisticService = statisticService {
            
            let bestGame = statisticService.bestGame
            
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            resultMessage = """
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsAmount)
                Рекорд: \(bestGame.correct)\\\(presenter.questionsAmount) (\(bestGame.date.dateTimeString))
                Средняя точность: \(accuracy)%
            """
        }
        return resultMessage
        
    }
    
    func chooseIsEnableButtons(_ enabled: Bool){
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }
    
    func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetGame()
            activityIndicator.startAnimating()
        }
        
        alertPresenter.showAlert(model: model, from: self)
    }
    
}

extension MovieQuizViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
}
