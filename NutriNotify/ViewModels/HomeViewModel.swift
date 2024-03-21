//
//  HomeViewModel.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/21.
//

import Foundation

class HomeViewModel {
    
    var suppList: [SupplementEntity]? = []
    
    init() {
        suppList = DataManager.shared.fetchSupplement()
        
    }
    
}
