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

class RxHomeViewModel {
    
    var supplements: [SupplementEntity]
    
    var sections: BehaviorRelay<[SectionOfSupplementData]>
    let dataSource: RxTableViewSectionedReloadDataSource<SectionOfSupplementData>
    
    init(supplements: [SupplementEntity]) {
        self.supplements = supplements
        
        self.sections = BehaviorRelay<[SectionOfSupplementData]>(value: [SectionOfSupplementData(header: "First section", items: supplements)])

        dataSource = RxTableViewSectionedReloadDataSource<SectionOfSupplementData>(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as! HomeTableViewCell
            cell.configure(item)
            return cell
        })
    }

    // 셀 삭제 메소드
    func deleteItem(at indexPath: IndexPath) {
        // sections의 items에서 indexPath에 해당하는 아이템을 삭제하고 section을 업데이트함
        var sectionsValue = sections.value
        var items = sectionsValue[indexPath.section].items
        
        // CoreData에서 supplement 삭제
        DataManager.shared.deleteSupplement(entity: items[indexPath.row])
        
        items.remove(at: indexPath.row)
        sectionsValue[indexPath.section] = SectionOfSupplementData(header: sectionsValue[indexPath.section].header, items: items)
        
        sections.accept(sectionsValue)
    }
    
    // ComposeVC에서 저장을 했을때 SupplementEntity를 tableView에 추가
    func addSupplement(_ supplement: SupplementEntity, isUpdate: Bool) {
        var sectionValue = sections.value

        var lastSectionItems = sectionValue.last?.items ?? []
        
//        // create한 경우만 insert
        if isUpdate == false {
            lastSectionItems.insert(supplement, at: 0)
        }
            
        sectionValue[sectionValue.count - 1] = SectionOfSupplementData(header: sectionValue[sectionValue.count - 1].header, items: lastSectionItems)

        sections.accept(sectionValue)
    }
}

struct SectionOfSupplementData {
  var header: String
  var items: [Item]
}

extension SectionOfSupplementData: SectionModelType {
  typealias Item = SupplementEntity

   init(original: SectionOfSupplementData, items: [Item]) {
    self = original
    self.items = items
  }
}
