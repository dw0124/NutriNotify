//
//  Supplement.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/05/10.
//

import Foundation


struct Supplement {
    var supplementEntity: SupplementEntity
    
    var name: String?
    var desc: String?
    var suppAlerts: [SuppAlert] = []
    
    init(supplemntEntity: SupplementEntity) {
        self.supplementEntity = supplemntEntity
        self.name = supplementEntity.name
        self.desc = supplementEntity.description
        
        if let suppAlertEntities = supplemntEntity.suppAlerts?.array as? [SuppAlertEntity] {
            self.suppAlerts = suppAlertEntities.map { SuppAlert(suppAlertEntity: $0) }
        } else {
            self.suppAlerts = []
        }
    }
    
    mutating func setSuppAlerts(suppAlerts: [SuppAlert]) {
        self.suppAlerts = suppAlerts
    }
}

struct SuppAlert {
    var suppAlertEntity: SuppAlertEntity
    
    var id: UUID?
    var alertTime: Date?
    var isTaken: Bool
    var weekday: [Int]?
    
    init(suppAlertEntity: SuppAlertEntity) {
        self.suppAlertEntity = suppAlertEntity
        self.id = suppAlertEntity.id
        self.alertTime = suppAlertEntity.alertTime
        self.isTaken = suppAlertEntity.isTaken
        self.weekday = suppAlertEntity.weekday
    }
}
