//
//  RxTestViewModel.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/21.
//

import Foundation
import RxSwift

class RxTestViewModel {
    
    var supplementList: Observable<[SupplementEntity]>

    init() {
        let supplements = DataManager.shared.fetchSupplement()
        supplementList = Observable.of(supplements)
    }
    
}
