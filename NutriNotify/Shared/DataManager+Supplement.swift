//
//  DataManager+Supplement.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/07.
//

import Foundation
import CoreData
import UserNotifications

extension DataManager {
    func createSupplement(name: String, desc: String, completion: ((SupplementEntity) -> ())? = nil) {
        mainContext.perform {
            let newSupplemnt = SupplementEntity(context: self.mainContext)
            
            newSupplemnt.name = name
            newSupplemnt.desc = desc
            
            self.saveMainContext()
            
            completion?(newSupplemnt)
        }
    }
    
    func fetchSupplement() -> [SupplementEntity] {
        var list: [SupplementEntity] = []
        
        // 블록이 모두 완료된 다음 리턴
        mainContext.performAndWait {
            let request: NSFetchRequest<SupplementEntity> = SupplementEntity.fetchRequest()
            
            let sortByName = NSSortDescriptor(key: #keyPath(SupplementEntity.name), ascending: true)
            request.sortDescriptors = [sortByName]
            
            do {
                list = try mainContext.fetch(request)
            } catch {
                print(error)
            }
        }
        
        return list
    }
    
    func updateSupplement(supplement: SupplementEntity, name: String, desc: String, completion: (() -> ())? = nil) {
        supplement.name = name
        supplement.desc = desc
        
        self.saveMainContext()
        
        completion?()
    }
    
    func deleteSupplement(entity: SupplementEntity) {
        mainContext.perform {
            print("del supp")
            self.mainContext.delete(entity)
            self.deleteSuppAlerts(for: entity)  // supAlert + local notification 삭제
            self.saveMainContext()
        }
    }
    
    // Supplement와 연관된 SuppAlert를 삭제
    func deleteSuppAlerts(for supplement: SupplementEntity) {
        guard let suppAlerts = supplement.suppAlert?.array as? [SuppAlertEntity] else {
            return
        }
        let center = UNUserNotificationCenter.current()
        
        for suppAlert in suppAlerts {
            mainContext.delete(suppAlert)
            
            // local notification 삭제
            center.removePendingNotificationRequests(withIdentifiers: [suppAlert.id?.uuidString ?? "localNotification"])
        }
        
        saveMainContext()
    }
    
    func deleteAll(entities: [SupplementEntity]) {
        mainContext.perform {
            entities.forEach {
                self.mainContext.delete($0)
            }
            self.saveMainContext()
        }
    }
}

import RxSwift

// Rx+DataManager
extension DataManager {
    func rxCreateSupplement(name: String, desc: String) -> Observable<SupplementEntity> {
        return Observable.create { observer in
            let newSupplemnt = SupplementEntity(context: self.mainContext)
            newSupplemnt.name = name
            newSupplemnt.desc = desc
            
            self.saveMainContext()
            
            observer.onNext(newSupplemnt)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func rxUpdateSupplement(supplement: SupplementEntity, name: String, desc: String) -> Observable<SupplementEntity> {
        return Observable.create { observer in
            supplement.name = name
            supplement.desc = desc
            
            self.saveMainContext()
            
            return Disposables.create()
        }
    }
}
