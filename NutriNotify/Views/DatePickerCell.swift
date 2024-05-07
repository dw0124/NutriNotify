import UIKit
import SnapKit

class DatePickerCell: UITableViewCell {
    static let identifier = "DatePickerCell"
    
    
    // 요일 배열
    let daysOfWeek = ["월", "화", "수", "목", "금", "토", "일"]
    
    private let weekdayButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 3
        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return stackView
    }()
    
    private var dayButtons: [UIButton] = []
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    var alertTextLabel: UILabel = {
        var label = UILabel()
        label.text = "알림"
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        var datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .time
        
        datePicker.locale = Locale(identifier: "ko-KR")
        
        //datePicker.subviews.first?.subviews.last?.backgroundColor = .clear // background color for time part
        datePicker.addTarget(self, action: #selector(didSelectedTime(_:)), for: .editingDidEnd)
        return datePicker
    }()
    
    var didSelectTime: ((Date) -> Void)?
    
    @objc func didSelectedTime(_ sender: UIDatePicker) {
        didSelectTime?(sender.date)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupCell() {
        
        // 요일 버튼 생성 및 설정
        for day in daysOfWeek {
            let button = UIButton(type: .custom)
            button.setTitle(day, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitleColor(.systemGray4, for: .selected)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .clear
            button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
            
            addSubview(button)
            dayButtons.append(button)
        }
        
        // contentView에 stackView 추가
        contentView.addSubview(stackView)
        
        dayButtons.forEach {
            weekdayButtonStackView.addArrangedSubview($0)
        }
        
        stackView.addArrangedSubview(weekdayButtonStackView)
        
        // alertTextLabel과 datePicker를 stackView에 추가
        //stackView.addArrangedSubview(alertTextLabel)
        stackView.addArrangedSubview(datePicker)
    }
    
    private func setupLayout() {
        // stackView의 제약 조건 설정
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
    
    // 요일 버튼 탭
    @objc private func dayButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if let dayIndex = dayButtons.firstIndex(of: sender), dayIndex < daysOfWeek.count {
            let selectedDay = daysOfWeek[dayIndex]
            
            print("\(selectedDay): \(dayIndex)")
        }
    }
}
