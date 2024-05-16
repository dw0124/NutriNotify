//
//  RxDataSourceViewModel.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/22.
//

import RxSwift
import RxDataSources

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct SectionOfSuppData {
  var header: String
  var items: [Item]
}

extension SectionOfSuppData: SectionModelType {
  typealias Item = Supplement

   init(original: SectionOfSuppData, items: [Item]) {
    self = original
    self.items = items
  }
}

class RxHomeViewModel {
    var disposeBag = DisposeBag()
    
    var supplementsSubject: BehaviorSubject<[SupplementEntity]>!
    
    var sectionss: BehaviorRelay<[SectionOfSuppData]> = BehaviorRelay(value: [])
    
    init(supplements: [SupplementEntity]) {
        supplementsSubject = BehaviorSubject(value: supplements)
        
        supplementsSubject
            .map { [weak self] supplements in
                self?.filterToday(supplements) ?? []
            }
            .bind(to: sectionss)
            .disposed(by: disposeBag)
        
    }
    
    // 셀 삭제 메소드
    func deleteItem(at indexPath: IndexPath) {
        // sections의 items에서 indexPath에 해당하는 아이템을 삭제하고 section을 업데이트함
        var sectionsValue = sectionss.value
        var items = sectionsValue[indexPath.section].items
        
        // CoreData에서 supplement 삭제
        DataManager.shared.deleteSupplement(entity: items[indexPath.row].supplementEntity)
        
        items.remove(at: indexPath.row)
        sectionsValue[indexPath.section] = SectionOfSuppData(header: sectionsValue[indexPath.section].header, items: items)
        
        sectionss.accept(sectionsValue)
    }
    
    // ComposeVC에서 저장을 했을때 SupplementEntity를 tableView에 추가
    func addSupplement(_ supplement: SupplementEntity, isUpdate: Bool) {
        do{
            var newSupplements = try supplementsSubject.value()
            
            // create한 경우만 insert
            if isUpdate == false {
                newSupplements.insert(supplement, at: 0)
            } else {
                if let firstIndex = newSupplements.firstIndex(where: { $0.id == supplement.id }) {
                    newSupplements[firstIndex] = supplement
                }
            }
            
            supplementsSubject.onNext(newSupplements)
        }catch {
            print(error)
        }
    }
    
    func filterToday(_ supplements: [SupplementEntity]) -> [SectionOfSuppData] {
        // 오늘 요일 : 1~7: 일~토 -> 0~6
        var weekday = Calendar.current.component(.weekday, from: .now) - 2
        weekday = weekday == -1 ? 6 : weekday
        
        // 섹션을 저장할 배열
        var suppplementArr: [Supplement] = []

        var index = 0
        
        for supplement in supplements {
            
            var newSupp = Supplement(supplemntEntity: supplement)
            
            if let suppAlerts = supplement.suppAlerts?.array as? [SuppAlertEntity] {
                // 해당 요일의 알림만 필터링
                let alerts = suppAlerts
                    .filter { $0.weekday?[weekday] == 1 }
                    .map { SuppAlert(suppAlertEntity: $0) }
                
                newSupp.setSuppAlerts(suppAlerts: alerts)
            }
            
            if newSupp.suppAlerts.count > 0 {
                suppplementArr.append(newSupp)
            }
            
            index += 1
        }
        
        return [SectionOfSuppData(header: "First section", items: suppplementArr)]
    }
}
