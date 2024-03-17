//
//  DataManager+Supplement.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/07.
//

import Foundation
import CoreData

extension DataManager {
    func createSupplement(name: String, completion: (() -> ())? = nil) {
        mainContext.perform {
            let newSupplemnt = SupplementEntity(context: self.mainContext)
            
            newSupplemnt.name = name
            
            self.saveMainContext()
            
            completion?()
        }
    }
    
    func fetchSupplement() -> [SupplementEntity] {
        var list = [SupplementEntity]()
        
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
    
    func deleteSupplement(entity: SupplementEntity) {
        mainContext.perform {
            self.mainContext.delete(entity)
            self.saveMainContext()
        }
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
