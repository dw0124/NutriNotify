//
//  AlertCheckBoxCell.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/15.
//

import UIKit
import Foundation
import SnapKit

class AlertCheckBoxCell: UICollectionViewCell {
    static let identifier = "AlertCheckBoxCell"
    
    // 초기화 및 레이아웃 설정
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with suppAlert: [SuppAlertEntity]) {
        
    }
}
