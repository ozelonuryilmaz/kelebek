//
//  BackgroundTaskManager.swift
//  kelebek
//
//  Created by Onur Yılmaz on 13.03.2025.
//

import BackgroundTasks

protocol IBackgroundLocationTaskManager {
    func registerBackgroundTasks()
    func scheduleBackgroundTask()
}

final class BackgroundLocationTaskManager: IBackgroundLocationTaskManager {

    static let shared: IBackgroundLocationTaskManager = BackgroundLocationTaskManager()
    
    private let locaitonUpdateTaskIdentifier = "com.onuryilmaz.kelebek.backgroundLocationTaskUpdate"

    private init() { }
}

// MARK: Register for AppDelegate
extension BackgroundLocationTaskManager {
   
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: self.locaitonUpdateTaskIdentifier,
            using: nil,
            launchHandler: { [weak self] task in
                self?.handleBackgroundTask(task)
            }
        )
    }
    
    private func handleBackgroundTask(_ task: BGTask) {
        guard let proccessingTask = task as? BGProcessingTask else { return }
        
        let locationManager: ILocationManager = LocationManager()
        locationManager.startUpdatingLocation()

        proccessingTask.expirationHandler = {
            locationManager.stopUpdatingLocation()
        }

        proccessingTask.setTaskCompleted(success: true)
    }
}

// MARK: Trigger for LocationManager
extension BackgroundLocationTaskManager {
    
    func scheduleBackgroundTask() {
        let taskIdentifier = self.locaitonUpdateTaskIdentifier
        
        Task { [weak self] in
            guard let self else { return }
            
            let pendingTasks = await BGTaskScheduler.shared.pendingTaskRequests()
            if pendingTasks.contains(where: { $0.identifier == taskIdentifier }) {
                return
            }
            
            let request = BGProcessingTaskRequest(identifier: taskIdentifier)
            request.requiresNetworkConnectivity = false
            request.requiresExternalPower = false
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // en az 15 dakika sonra Apple çalıştırır

            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Background Task Hatası: \(error)")
            }
        }
    }
}
