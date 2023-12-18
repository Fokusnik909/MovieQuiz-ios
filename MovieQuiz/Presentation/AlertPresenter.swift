//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Артур  Арсланов on 18.12.2023.
//

import Foundation
import UIKit

class AlertPresenter {
     func showAlert( model: AlertModel, from viewController: UIViewController){
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true)
    }
}
