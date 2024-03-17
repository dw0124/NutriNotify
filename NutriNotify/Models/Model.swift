//
//  Model.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/06.
//

import Foundation

struct NutritionSupplement {
    var name: String
    var notifications: [Notification]
}

struct Notification {
    var time: Date
    var isChecked: Bool
}
