//
//  AlertCheckBoxCell.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/15.
//

import UIKit
import SnapKit

class AlertCheckBoxCell: UICollectionViewCell {
    static let identifier = "AlertCheckBoxCell"
    
    var suppAlert: SuppAlert! = nil
    
    // UI 요소
    let stackView = UIStackView()
    let alertTimeLabel = UILabel()
    let button = UIButton()
    
    // 초기화 및 레이아웃 설정
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with suppAlert: SuppAlert) {
        // suppAlert에서 데이터를 가져와서 UI 업데이트
        self.suppAlert = suppAlert
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // 시간 형식으로 포맷 설정
        
        alertTimeLabel.text = dateFormatter.string(from: suppAlert.alertTime!) // 시간만 표시
        button.isSelected = suppAlert.suppAlertEntity.isTaken // isTaken 값에 따라 버튼의 선택 상태 변경
    }
    
    // UI 구성 및 레이아웃 설정
    private func setupCell() {
        contentView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.alignment = .center
        //stackView.distribution = .equalCentering
        stackView.spacing = 0
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()//.inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        stackView.addArrangedSubview(alertTimeLabel)
        stackView.addArrangedSubview(button)
        
        alertTimeLabel.snp.makeConstraints {
            $0.height.equalTo(14)
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        button.snp.makeConstraints {
            $0.width.equalTo(button.snp.height)
        }
        
        button.imageView?.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        button.tintColor = .black
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // 버튼 탭 이벤트 처리
    @objc func buttonTapped() {
        button.isSelected = !button.isSelected
        
        suppAlert?.isTaken = button.isSelected
        suppAlert.suppAlertEntity.isTaken = button.isSelected
        DataManager.shared.saveMainContext()
    }
}
