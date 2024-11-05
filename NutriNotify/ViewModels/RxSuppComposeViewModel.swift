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
    var weekdays: BehaviorRelay<[[Int]?]> = BehaviorRelay(value: [[1,1,1,1,1,1,1]])
    
    init(_ supplement: SupplementEntity? = nil) {
        guard let supplement = supplement else { return }
        
        self.supplement = supplement
        
        name.accept(supplement.name)
        description.accept(supplement.desc)
        
        guard let suppAlerts = supplement.suppAlerts?.array as? [SuppAlertEntity] else { return }
        let suppAlertTimes = suppAlerts.map { $0.alertTime }
        
        // 요일 테스트
        let weekdays = suppAlerts.map { $0.weekday }
        
        self.weekdays.accept(weekdays)
        
        self.alertTimes.accept(suppAlertTimes)
    }
    
    // 알림 추가
    func alertTimeAppend() {
        alertTimes.accept(alertTimes.value + [Date()])
        weekdays.accept(weekdays.value + [[1,1,1,1,1,1,1]])
    }
    
    // 알림 삭제
    func deleteItem(at indexPath: IndexPath) {
        var alertTimesValue = alertTimes.value
        alertTimesValue.remove(at: indexPath.row)
        alertTimes.accept(alertTimesValue)
        
        var weekdayValue = weekdays.value
        weekdayValue.remove(at: indexPath.row)
        weekdays.accept(weekdayValue)
    }
    
    // 요일 선택
    func didSelectWeekday(row: Int, index: Int) {
        var weekdaysValue = weekdays.value
        let toggle = weekdaysValue[row]?[index] == 1 ? 0 : 1
        
        weekdaysValue[row]?[index] = toggle
        
        weekdays.accept(weekdaysValue)
    }
    
    // Supplement를 생성 또는 업데이트하는 메소드
    func saveSupp() -> Observable<(SupplementEntity, Bool)> {
        return Observable.create { observer in
            
            guard let nameValue = self.name.value, let descriptionValue = self.description.value else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            var isUpdate = false
            
            // supplement가 있다면 update / 없으면 생성
            let supplementObservable: Observable<SupplementEntity>
            if let supplement = self.supplement {
                isUpdate = true
                DataManager.shared.deleteSuppAlerts(for: supplement)
                supplementObservable = DataManager.shared.rxUpdateSupplement(supplement: supplement, name: nameValue, desc: descriptionValue)
            } else {
                isUpdate = false
                supplementObservable = DataManager.shared.rxCreateSupplement(name: nameValue, desc: descriptionValue)
            }
            
            // supplementObservable을 구독하여 flatMap을 통해 Observable<SupplementEntity>를 방출
            // -> 변경된 supplement를 HomeVC에 전달하기 위함
            let disposable = supplementObservable
                .flatMap {
                    self.createSuppAlerts(for: $0)  // SuppAlert 생성
                }
                .flatMap {
                    DataManager.shared.sortSuppAlerts($0)   // 알림 시간으로 정렬
                }
                .subscribe(onNext: { supplement in
                    observer.onNext((supplement, isUpdate))
                    observer.onCompleted()
                })
            
            return Disposables.create { disposable.dispose() }
        }
    }

    // suppAlert를 생성하는 메소드
    private func createSuppAlerts(for supplement: SupplementEntity) -> Observable<SupplementEntity> {
        return Observable<SupplementEntity>.create { observer in
            for (index,alertTime) in self.alertTimes.value.enumerated() {
                guard let alertTime = alertTime else { continue } // nil이면 다음 반복으로 건너뜁니다.
                guard let weekday = self.weekdays.value[index] else { continue }
                
                // SuppAlertEntity를 생성합니다.
                DataManager.shared.createSuppAlert2(for: supplement, weekday: weekday, alertTime: alertTime, isTaken: false) { [weak self] supp, suppAlert in
                    // 생성된 SuppAlertEntity에 대한 local notification을 예약합니다.
                    let id: String = suppAlert.id?.uuidString ?? "localNotification"
                    self?.scheduleLocalNotification(id: id, for: alertTime, weekdays: weekday, title: supplement.name ?? "제목없음", body: supplement.desc ?? "설명 없음")
                    
                    if index == (self?.alertTimes.value.count)! - 1 {
                        observer.onNext(supp) // 작업이 완료되었음을 나타냅니다.
                    }
                }
            }
            
            return Disposables.create()
        }
    }

    // Local Notification 생성
    private func scheduleLocalNotification(id: String , for date: Date, weekdays: [Int], title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(title)"
        content.body = "\(body)"
        
        var dateComponenetWeekdays: [Int] = []
        
        for (index, weekday) in weekdays.enumerated() {
            if weekday != 0 {
                let indexForWeekday = index + 2 == 8 ? 1 : index + 2
                dateComponenetWeekdays.append(indexForWeekday)
            }
        }
        
        for weekday in dateComponenetWeekdays {
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.hour, .minute], from: date)
            dateComponents.weekday = weekday
            
            let idWithWeekday = "\(id)_\(weekday)"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: idWithWeekday, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }
}
