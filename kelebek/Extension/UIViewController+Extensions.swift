//
//  UIViewController+Extensions.swift
//  kelebek
//
//  Created by Onur Yılmaz on 6.03.2025.
//

import UIKit

extension UIViewController {

    func showSystemAlert(
        title: String,
        message: String,
        positiveButtonText: String? = "Tamam",
        positiveButtonClickListener: (() -> Void)? = nil,
        negativeButtonText: String? = nil,
        negativeButtonClickListener: (() -> Void)? = nil,
        tintColor: UIColor = UIColor.blue
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor

        let posAction = UIAlertAction(title: positiveButtonText, style: .default,
                                      handler: { _ in
                                          positiveButtonClickListener?()
                                      })
        alert.addAction(posAction)

        var negAction: UIAlertAction? = nil
        if let negativeButtonText = negativeButtonText {
            negAction = UIAlertAction(title: negativeButtonText, style: .cancel,
                                      handler: { _ in
                                          negativeButtonClickListener?()
                                      })
            alert.addAction(negAction!)
        }

        present(alert, animated: true, completion: nil)
    }
}
