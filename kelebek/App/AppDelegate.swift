//
//  AppDelegate.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Start App
        self.startApp()

        // Register Background Task
        BackgroundLocationTaskManager.shared.registerBackgroundTasks()

        return true
    }
}

extension AppDelegate {
    
    private func startApp() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let homeViewController = HomeViewBuilder.build()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
