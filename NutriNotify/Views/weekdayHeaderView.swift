//
//  weekdayHeaderView.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/05/21.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class WeekdayHeaderView: UITableViewHeaderFooterView {
    static let identifier = "WeekdayHeaderView"
    
    var disposeBag = DisposeBag()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    let selectedWeekdaySubject = PublishSubject<Int>()
   
    let daysOfWeek: [String] = ["전체", "월", "화", "수", "목", "금", "토", "일"]

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

        // Create buttons for each day of the week
        daysOfWeek.enumerated().forEach { (index, day) in
            let button = UIButton()
            button.setTitle(day, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.backgroundColor = .white
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 0.3
            button.addTarget(self, action: #selector(selectedWeekday(_:)), for: .touchUpInside)
            button.tag = index
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc func selectedWeekday(_ sender: UIButton) {
        let selectedIndex = sender.tag
        // 버튼이 눌린 인덱스를 Subject를 통해 방출
        selectedWeekdaySubject.onNext(selectedIndex)
    }
}
