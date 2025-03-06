//
//  BaseViewModel.swift
//  kelebek
//
//  Created by Onur Yılmaz on 6.03.2025.
//

import Foundation

class BaseViewModel {

    deinit {
        print("killed: \(type(of: self))")
    }
}
