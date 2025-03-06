//
//  BaseViewController.swift
//  kelebek
//
//  Created by Onur Yılmaz on 6.03.2025.
//

import UIKit

class KelebekBaseViewController: UIViewController {

    deinit {
        print("killed: \(type(of: self))")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initDidLoad()
    }

    // just base sub class
    internal func initDidLoad() {
        self.initialComponents()
        self.setupView()
        self.registerEvents()
    }

    // for all sub class
    func setupView() { }

    // for all sub class
    func initialComponents() { }

    // for all sub class
    func registerEvents() { }
}
