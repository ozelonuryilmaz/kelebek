//
//  HomeViewBuilder.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit

enum HomeViewBuilder {
    
    static func build() -> UIViewController {
        let viewModel = HomeViewModel()
        return HomeViewController(viewModel: viewModel)
    }
}
