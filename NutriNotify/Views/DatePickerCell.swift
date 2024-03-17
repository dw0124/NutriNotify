import UIKit
import SnapKit

class DatePickerCell: UITableViewCell {
    static let identifier = "DatePickerCell"
    
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
        datePicker.addTarget(self, action: #selector(didSelectedTime(_:)), for: .valueChanged)
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
        // contentView에 stackView 추가
        contentView.addSubview(stackView)
        
        // alertTextLabel과 datePicker를 stackView에 추가
        stackView.addArrangedSubview(alertTextLabel)
        stackView.addArrangedSubview(datePicker)
    }
    
    private func setupLayout() {
        // stackView의 제약 조건 설정
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
    }
}
