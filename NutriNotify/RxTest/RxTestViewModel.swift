//
//  RxTestViewModel.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/21.
//

import Foundation
import RxSwift
import RxDataSources

class RxTestViewModel {
    var supplements: [SupplementEntity]
    var supplementList: Observable<[SupplementEntity]>

    init() {
        self.supplements = DataManager.shared.fetchSupplement()
        supplementList = Observable.of(supplements)
    }
}
