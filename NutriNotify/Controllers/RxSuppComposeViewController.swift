//
//  RxSuppComposeViewController.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/25.
//

import UIKit
import Foundation
import RxSwift

class RxSuppComposeViewController: UIViewController, ViewModelBindableType {
    
    var disposeBag = DisposeBag()
    
    var viewModel: RxSuppComposeViewModel!
    
    var delegate: ComposeVCDelegate!
    
    private let tableView = UITableView()
    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    private let descriptionLabel = UILabel()
    private let descriptionTextField = UITextField()
    private let addButton = UIButton(type: .system)
    
    
    lazy var cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action:#selector(dismissVC))
    lazy var saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action:#selector(saveSupp))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationItem()
        setupUI()
        tapGestureDismissKeyboard()
    }
    
    func bindViewModel() {
        viewModel.name
            .bind(to: nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.description
            .bind(to: descriptionTextField.rx.text)
            .disposed(by: disposeBag)
        
        nameTextField.rx.text.orEmpty
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        
        descriptionTextField.rx.text.orEmpty
            .bind(to: viewModel.description)
            .disposed(by: disposeBag)
        
        viewModel.alertTimes
            .bind(to: tableView.rx.items(cellIdentifier: DatePickerCell.identifier, cellType: DatePickerCell.self)) { row, element, cell in
                cell.alertTextLabel.text = "알림\(row + 1)"
                cell.datePicker.date = element ?? Date()

                cell.updateSelectionStates(for: self.viewModel.weekdays.value[row])
                
                cell.didSelectTime = { [weak self] time in
                    guard var updateAlertTime = self?.viewModel.alertTimes.value else { return }
                    updateAlertTime[row] = time
                    self?.viewModel.alertTimes.accept(updateAlertTime)
                }
                
                cell.didSelectWeekday = { [weak self] index in
                    self?.viewModel.didSelectWeekday(row: row, index: index)
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] in self?.viewModel.deleteItem(at: $0) })
            .disposed(by: disposeBag)
        
        // 제목을 입력하지 않으면 네비게이션 오른쪽 저장버튼 비활성화
        viewModel.name
            .map { !($0?.isEmpty ?? true) }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
}

extension RxSuppComposeViewController {
    func setNavigationItem() {
       self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func saveSupp() {
        viewModel.saveSupp()
            .subscribe(onNext: { (supplement, isUpdate) in
                self.delegate.didSaveSupplement(supplement, isUpdate: isUpdate)
                self.dismissVC()
            })
            .disposed(by: disposeBag)
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    @objc func addCell() {
        viewModel.alertTimeAppend()
        tableView.reloadData()
    }
    
    // UI설정 및 레이아웃
    func setupUI() {
        view.backgroundColor = .white
        
        // 제목 label
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        let string = "* 알림 제목"

        // NSMutableAttributedString을 사용하여 문자열 속성 지정
        let attributedString = NSMutableAttributedString(string: string)

        // 특정 범위에 속성 지정
        let range = NSRange(location: 0, length: 1) // "Hello" 부분에 적용
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range) // 텍스트 색상을 빨간색으로 변경
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14), range: range) // 폰트를 볼드체로 변경
        
        nameLabel.attributedText = attributedString
        
        // 제목 텍스트 필드
        nameTextField.text = "제목"
        nameTextField.borderStyle = .roundedRect
        
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .medium)
        descriptionLabel.text = "알림 내용"
        
        // 내용 텍스트필드
        descriptionTextField.text = "내용"
        descriptionTextField.borderStyle = .roundedRect
        
        // 알림 추가 버튼
        addButton.setTitle("알림 추가", for: .normal)
        addButton.addTarget(self, action: #selector(addCell), for: .touchUpInside)
        
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(descriptionTextField)
        stackView.addArrangedSubview(addButton)
        
        stackView.setCustomSpacing(16, after: nameTextField)
        stackView.setCustomSpacing(16, after: descriptionTextField)
        
        view.addSubview(stackView)
        
        nameLabel.snp.makeConstraints { $0.height.equalTo(24) }
        nameTextField.snp.makeConstraints { $0.height.equalTo(44) }
        descriptionLabel.snp.makeConstraints { $0.height.equalTo(24) }
        descriptionTextField.snp.makeConstraints { $0.height.equalTo(44) }
        addButton.snp.makeConstraints { $0.height.equalTo(32) }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // 테이블 뷰
        view.addSubview(tableView)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: DatePickerCell.identifier)
        tableView.isEditing = true
        tableView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(0)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
    }
}

extension RxSuppComposeViewController {
    func tapGestureDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

protocol ComposeVCDelegate: AnyObject {
    func didSaveSupplement(_ supplement: SupplementEntity, isUpdate: Bool)
}
