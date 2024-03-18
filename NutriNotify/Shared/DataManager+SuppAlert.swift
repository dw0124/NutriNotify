//
//  DataManager+SuppAlert.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/07.
//

import Foundation
import CoreData

extension DataManager {
    func createSuppAlert(for supplement: SupplementEntity, alertTime: Date, isTaken: Bool, completion: ((SuppAlertEntity) -> ())? = nil) {
        mainContext.perform {
            let newSuppAlert = SuppAlertEntity(context: self.mainContext)
            
            newSuppAlert.alertTime = alertTime
            newSuppAlert.isTaken = isTaken
            
            supplement.addToSuppAlert(newSuppAlert)
            
            self.saveMainContext()
            
            completion?(newSuppAlert)
        }
    }
    
    func updateSuppAlert(suppAlert: SuppAlertEntity, alertTime: Date, isTaken: Bool = false) {
        suppAlert.alertTime = alertTime
        suppAlert.isTaken = isTaken
        
        self.saveMainContext()
    }
    
    func delete(entity: SuppAlertEntity) {
        mainContext.perform {
            self.mainContext.delete(entity)
            self.saveMainContext()
        }
    }
}
