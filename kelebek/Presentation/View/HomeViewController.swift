//
//  HomeViewController.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit

final class HomeViewController: UIViewController {
    
    // MARK: Inject
    private let viewModel: IHomeViewModel
    
    init(viewModel: IHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HomeViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("düştü")
    }
}
