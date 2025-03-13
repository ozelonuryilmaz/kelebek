//
//  BackgroundTaskManager.swift
//  kelebek
//
//  Created by Onur Yılmaz on 13.03.2025.
//

import BackgroundTasks

protocol IBackgroundLocationTaskManager: AnyObject {
    func registerBackgroundTasks()
    func scheduleBackgroundTask()
}

final class BackgroundLocationTaskManager: IBackgroundLocationTaskManager {

    static let shared: IBackgroundLocationTaskManager = BackgroundLocationTaskManager()
    
    private lazy var locationManager: ILocationManager? = LocationManager()
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
   
        locationManager?.startUpdatingLocation()

        proccessingTask.expirationHandler = { [weak self] in
            self?.locationManager?.stopUpdatingLocation()
            self?.locationManager = nil
        }

        proccessingTask.setTaskCompleted(success: true)
    }
}

// MARK: Trigger for LocationManager
extension BackgroundLocationTaskManager {
    
    func scheduleBackgroundTask() {
        let taskIdentifier = self.locaitonUpdateTaskIdentifier
        
        Task { 
            let pendingTasks = await BGTaskScheduler.shared.pendingTaskRequests()
            if pendingTasks.contains(where: { $0.identifier == taskIdentifier }) {
                return
            }
            
            let request = BGProcessingTaskRequest(identifier: taskIdentifier)
            request.requiresExternalPower = false
            request.requiresNetworkConnectivity = false
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // en az 15 dakika sonra Apple çalıştırır

            do {
                try BGTaskScheduler.shared.submit(request)
                print("Background Task Başarılı")
            } catch {
                print("Background Task Hatası: \(error)")
            }
        }
    }
}
