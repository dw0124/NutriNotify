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

class RxDataSourceViewModel {
    
    var supplements: [SupplementEntity]
    var sections: BehaviorRelay<[SectionOfCustomData]>
    
    let dataSource: RxTableViewSectionedReloadDataSource<SectionOfCustomData>
    
    init() {
        self.supplements = DataManager.shared.fetchSupplement()
        self.sections = BehaviorRelay<[SectionOfCustomData]>(value: [SectionOfCustomData(header: "First section", items: self.supplements)])
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(
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
        sectionsValue[indexPath.section] = SectionOfCustomData(header: sectionsValue[indexPath.section].header, items: items)
        
        sections.accept(sectionsValue)
    }
    
}

struct SectionOfCustomData {
  var header: String
  var items: [Item]
}

extension SectionOfCustomData: SectionModelType {
  typealias Item = SupplementEntity

   init(original: SectionOfCustomData, items: [Item]) {
    self = original
    self.items = items
  }
}
