//
//  UIViewController+Extensions.swift
//  kelebek
//
//  Created by Onur Yılmaz on 6.03.2025.
//

import UIKit

enum AlertPreferredActionType {
    case positive
    case negative
    case nothing
}

extension UIViewController {

    func showSystemAlert(
        title: String,
        message: String,
        positiveButtonText: String? = "Tamam",
        positiveButtonClickListener: (() -> Void)? = nil,
        negativeButtonText: String? = nil,
        negativeButtonClickListener: (() -> Void)? = nil,
        preferredActionType: AlertPreferredActionType = .nothing,
        tintColor: UIColor = UIColor.blue
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor

        // Positive Action
        let posAction = UIAlertAction(title: positiveButtonText, style: .default,
                                      handler: { _ in
                                          positiveButtonClickListener?()
                                      })
        alert.addAction(posAction)

        // Negative Action
        var negAction: UIAlertAction? = nil
        if let negativeButtonText = negativeButtonText {
            negAction = UIAlertAction(title: negativeButtonText, style: .cancel,
                                      handler: { _ in
                                          negativeButtonClickListener?()
                                      })
            alert.addAction(negAction!)
        }

        switch preferredActionType {
        case .positive:
            alert.preferredAction = posAction
        case .negative:
            alert.preferredAction = negAction
        case .nothing:
            alert.preferredAction = nil
        }

        present(alert, animated: true, completion: nil)
    }
}
