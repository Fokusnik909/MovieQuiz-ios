//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Артур  Арсланов on 21.01.2024.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(model: AlertModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func chooseIsEnableButtons(_ enabled: Bool)
}
