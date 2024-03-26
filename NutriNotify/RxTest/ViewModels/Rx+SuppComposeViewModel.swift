//
//  Rx+SuppComposeViewModel.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/25.
//

import Foundation
import UserNotifications

import RxSwift
import RxRelay
import RxDataSources

class RxSuppComposeViewModel {
    var disposeBag = DisposeBag()
    
    var supplement: SupplementEntity?
    
    var name: BehaviorRelay<String?> = BehaviorRelay(value: "")
    var description: BehaviorRelay<String?> = BehaviorRelay(value: "")
    var alertTimes: BehaviorRelay<[Date?]> = BehaviorRelay(value: [Date()])
    
    init(_ supplement: SupplementEntity? = nil) {
        guard let supplement = supplement else { return }
        
        self.supplement = supplement
        
        name.accept(supplement.name)
        description.accept(supplement.desc)
        
        guard let suppAlerts = supplement.suppAlert?.array as? [SuppAlertEntity] else { return }
        let suppAlertTimes = suppAlerts.map { $0.alertTime }
        
        self.alertTimes.accept(suppAlertTimes)
    }
    
    func alertTimeAppend() {
        alertTimes.accept(alertTimes.value + [Date()])
    }
    
    func deleteItem(at indexPath: IndexPath) {
        var alertTimesValue = alertTimes.value
        alertTimesValue.remove(at: indexPath.row)
        alertTimes.accept(alertTimesValue)
    }
    
//    func saveSupp() -> Observable<SupplementEntity> {
//
//        return Observable<SupplementEntity>.create { observer in
//
//            guard let nameValue = self.name.value, let descriptionValue = self.description.value else { return Disposables.create() }
//
//            // supplement가 있다면 update / 없으면 생성
//            if let supplement = self.supplement {
//                DataManager.shared.updateSupplement(supplement: supplement, name: nameValue, desc: descriptionValue) { [weak self] in
//                    // suppAlert목록 삭제 후 다시 생성
//                    DataManager.shared.deleteSuppAlerts(for: supplement)
//                    self?.createSuppAlerts(for: supplement)
//
//                    observer.onNext(supplement)
//                }
//            } else {
//                // SupplementEntity 생성
//                DataManager.shared.createSupplement(name: nameValue, desc: descriptionValue) { [weak self] supplement in
//                    self?.createSuppAlerts(for: supplement)
//
//                    observer.onNext(supplement)
//                }
//            }
//            // 작업이 완료되면 observer에게 완료 이벤트를 전달합니다.
//
//            return Disposables.create()
//        }
//    }
//
//    // suppAlert를 생성하는 메소드
//    private func createSuppAlerts(for supplement: SupplementEntity) {
//        for alertTime in alertTimes.value {
//
//            guard let alertTime = alertTime else { return }
//
//            // SuppAlertEntity 생성
//            DataManager.shared.createSuppAlert(for: supplement, alertTime: alertTime, isTaken: false) { [weak self] suppAlert in
//                // local notification 생성
//                let id: String = suppAlert.id?.uuidString ?? "localNotification"
//                self?.scheduleLocalNotification(id: id, for: alertTime, with: supplement.name ?? "제목없음")
//            }
//        }
//    }

    func saveSupp() -> Observable<SupplementEntity> {
        return Observable.create { observer in
            
            guard let nameValue = self.name.value, let descriptionValue = self.description.value else {
                //observer.onError(MyError.invalidInput) // 유효하지 않은 입력일 경우 에러 이벤트를 방출합니다.
                return Disposables.create()
            }
            
            // supplement가 있다면 update / 없으면 생성
            if let supplement = self.supplement {
                DataManager.shared.updateSupplement(supplement: supplement, name: nameValue, desc: descriptionValue) { [weak self] in
                    // suppAlert목록 삭제 후 다시 생성
                    DataManager.shared.deleteSuppAlerts(for: supplement)
                    self?.createSuppAlerts(for: supplement)
                        .subscribe(onNext: {
                            observer.onNext($0)
                            observer.onCompleted()
                        })
                        .disposed(by: self?.disposeBag ?? DisposeBag())
                }
            } else {
                // SupplementEntity 생성
                DataManager.shared.createSupplement(name: nameValue, desc: descriptionValue) { [weak self] supplement in
                    self?.createSuppAlerts(for: supplement)
                        .subscribe(onNext: {
                            observer.onNext($0)
                            observer.onCompleted()
                        })
                        .disposed(by: self?.disposeBag ?? DisposeBag())
                }
            }
            
            return Disposables.create()
        }
    }

    // suppAlert를 생성하는 메소드
    private func createSuppAlerts(for supplement: SupplementEntity) -> Observable<SupplementEntity> {
        return Observable<SupplementEntity>.create { observer in
            for (index,alertTime) in self.alertTimes.value.enumerated() {
                guard let alertTime = alertTime else { continue } // nil이면 다음 반복으로 건너뜁니다.
                
                // SuppAlertEntity를 생성합니다.
                DataManager.shared.createSuppAlert2(for: supplement, alertTime: alertTime, isTaken: false) { [weak self] supp, suppAlert in
                    // 생성된 SuppAlertEntity에 대한 local notification을 예약합니다.
                    let id: String = suppAlert.id?.uuidString ?? "localNotification"
                    self?.scheduleLocalNotification(id: id, for: alertTime, with: supplement.name ?? "제목없음")
                    
                    if index == (self?.alertTimes.value.count)! - 1 {
                        observer.onNext(supp) // 작업이 완료되었음을 나타냅니다.
                    }
                }
            }
            
            return Disposables.create()
        }
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
