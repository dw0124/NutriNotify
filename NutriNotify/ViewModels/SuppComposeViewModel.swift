//
//  SuppComposeViewModel.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/11.
//

import Foundation
import UserNotifications

class SuppComposeViewModel {
    
    var supplement: SupplementEntity?
    
    var name: String = ""
    var description: String = ""
    var alertTimes: [Date] = [Date()]
    
    init(_ supplement: SupplementEntity? = nil) {
        self.supplement = supplement
    }
    
    func saveSupp(_ completion: @escaping () -> Void) {
        
        // supplement가 있다면 update / 없으면 생성
        if let supplement = supplement {
            DataManager.shared.updateSupplement(supplement: supplement, name: name, desc: description) { [weak self] in
                // suppAlert목록 삭제 후 다시 생성
                DataManager.shared.deleteSuppAlerts(for: supplement)
                self?.createSuppAlerts(for: supplement)
            }
        } else {
            // SupplementEntity 생성
            DataManager.shared.createSupplement(name: name, desc: description) { [weak self] supplement in
                self?.createSuppAlerts(for: supplement)
            }
        }
        completion()
    }
    
    // suppAlert를 생성하는 메소드
    private func createSuppAlerts(for supplement: SupplementEntity) {
        for alertTime in alertTimes {
            // SuppAlertEntity 생성
            DataManager.shared.createSuppAlert(for: supplement, alertTime: alertTime, isTaken: false) { [weak self] suppAlert in
                // local notification 생성
                let id: String = suppAlert.id?.uuidString ?? "localNotification"
                self?.scheduleLocalNotification(id: id, for: alertTime, with: supplement.name ?? "제목없음")
            }
        }
    }
    
    func alertTimeAppend() {
        alertTimes.append(Date())
    }
 
    private func scheduleLocalNotification(id: String , for date: Date, with message: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(message) - Supplement Reminder"
        content.body = "\(message) - Don't forget to take your supplement!"
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
