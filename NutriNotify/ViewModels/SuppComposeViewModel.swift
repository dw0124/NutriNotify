//
//  SuppComposeViewModel.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/11.
//

import Foundation
import UserNotifications

class SuppComposeViewModel {
    
    var name: String = ""
    var description: String = ""
    var alertTimes: [Date] = [Date()]
    
    func saveSupp(_ completion: @escaping () -> Void) {
        DataManager.shared.mainContext.perform { [weak self] in
            // SupplementEntity
            let supplement = SupplementEntity(context: DataManager.shared.mainContext)
            supplement.name = self?.name
            supplement.desc = self?.description
            
            // SuppAlertEntity
            guard let notificationTimes = self?.alertTimes else { return }
            
            for alertTime in notificationTimes {
                let suppAlert = SuppAlertEntity(context: DataManager.shared.mainContext)
                suppAlert.alertTime = alertTime
                suppAlert.isTaken = false
                
                supplement.addToSuppAlert(suppAlert)
                
                // Schedule local notification
                self?.scheduleLocalNotification(for: alertTime, with: supplement.name ?? "제목없음")
            }
            DataManager.shared.saveMainContext()
            
            completion()
        }
    }
    
    func createSuppAlert() {
        alertTimes.append(Date())
    }
 
    private func scheduleLocalNotification(for date: Date, with message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Supplement Reminder"
        content.body = "\(message) - Don't forget to take your supplement!"
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(date)")
            }
        }
    }
}
