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
    
    // 전체 데이터
    var supplementsSubject: BehaviorSubject<[SupplementEntity]>!
    
    // 필터링 되어 테이블뷰에 보여질 데이터
    var sectionss: BehaviorRelay<[SectionOfSuppData]> = BehaviorRelay(value: [])
    
    var selectedWeekday: BehaviorRelay<Int> = {
        var weekday = Calendar.current.component(.weekday, from: .now) - 2
        weekday = weekday == -1 ? 6 : weekday
        return BehaviorRelay(value: weekday)
    }()
    
    init(supplements: [SupplementEntity]) {
        supplementsSubject = BehaviorSubject(value: supplements)
        
        Observable.combineLatest(supplementsSubject, selectedWeekday)
            .map { [weak self] supplements, weekday in
                self?.filterToday(supplements, weekday: weekday) ?? []
            }
            .bind(to: sectionss)
            .disposed(by: disposeBag)
    }
    
    // 셀 삭제 메소드
    func deleteItem(at indexPath: IndexPath) {
        do{
            // 전체 목록
            var newSupplements = try supplementsSubject.value()
            
            // 표시되고 있는 목록의 아이템
            let sectionsValue = sectionss.value
            let items = sectionsValue[indexPath.section].items
            
            // 전체 목록에서 삭제
            if let firstIndex = newSupplements.firstIndex(where: { $0.id == items[indexPath.row].supplementEntity.id }) {
                newSupplements.remove(at: firstIndex)
            }
            supplementsSubject.onNext(newSupplements)
            
            // CoreData에서 supplement 삭제
            DataManager.shared.deleteSupplement(entity: items[indexPath.row].supplementEntity)
        }catch {
            print(error)
        }
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
    
    func filterToday(_ supplements: [SupplementEntity], weekday: Int) -> [SectionOfSuppData] {
        
        if weekday == -1 {
            let supp = supplements.map { Supplement(supplemntEntity: $0) }
            return [SectionOfSuppData(header: "First section", items: supp)]
        }
        
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
