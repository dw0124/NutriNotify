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
    
    // Supplement를 생성 또는 업데이트하는 메소드
    func saveSupp() -> Observable<SupplementEntity> {
        
        return Observable<SupplementEntity>.create { observer in
            
            guard let nameValue = self.name.value, let descriptionValue = self.description.value else { return Disposables.create() }
            
            // supplementEntity를 생성 또는 업데이트해서 Observable로 저장
            var supplementObservable: Observable<SupplementEntity>
            
            // supplement가 있다면 update / 없으면 생성
            if let supplement = self.supplement {
                DataManager.shared.deleteSuppAlerts(for: supplement)
                supplementObservable = DataManager.shared.rxUpdateSupplement(supplement: supplement, name: nameValue, desc: descriptionValue)
            } else {
                supplementObservable = DataManager.shared.rxCreateSupplement(name: nameValue, desc: descriptionValue)
            }
            
            // supplementObservable을 구독하여 flatMap을 통해 Observable<SupplementEntity>를 방출
            // -> 변경된 supplement를 HomeVC에 전달하기 위함
            let disposable = supplementObservable
                .flatMap {
                    self.createSuppAlerts(for: $0)
                }
                .subscribe(onNext: {
                    observer.onNext($0)
                    observer.onCompleted()
                })
            
            return Disposables.create { disposable.dispose() }
        }
    }

    // suppAlert를 생성하는 메소드
    private func createSuppAlerts(for supplement: SupplementEntity) -> Observable<SupplementEntity> {
        
        print(#function)
        
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

    // Local Notification 생성
    private func scheduleLocalNotification(id: String , for date: Date, with message: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(message)"
        content.body = "\(message) - 드셨나요?"

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
