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
    
    private let tableView = UITableView()
    private let nameTextField = UITextField()
    private let descriptionTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationItem()
        setupUI()
    }
    
    func bindViewModel() {
        print(#function)
        
        nameTextField.text = viewModel.name.value
        descriptionTextView.text = viewModel.description.value
        
        nameTextField.rx.text.orEmpty
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text.orEmpty
            .bind(to: viewModel.description)
            .disposed(by: disposeBag)
        
        viewModel.alertTimes
            .bind(to: tableView.rx.items(cellIdentifier: DatePickerCell.identifier, cellType: DatePickerCell.self)) { row, element, cell in
                cell.alertTextLabel.text = "알림\(row + 1)"
                cell.datePicker.date = element ?? Date()

                cell.didSelectTime = { [weak self] time in
                    guard var updateAlertTime = self?.viewModel.alertTimes.value else { return }
                    updateAlertTime[row] = time
                    self?.viewModel.alertTimes.accept(updateAlertTime)
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] in self?.viewModel.deleteItem(at: $0) })
            .disposed(by: disposeBag)
    }
    
}

extension RxSuppComposeViewController {
    func setNavigationItem() {
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action:#selector(dismissVC))
        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action:#selector(saveSupp))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func saveSupp() {
        viewModel.saveSupp() {
            self.dismissVC()
        }
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
        
        // 텍스트 필드
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        nameTextField.placeholder = "영양제 이름"
        nameTextField.borderStyle = .roundedRect

        // 텍스트 뷰
        view.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        descriptionTextView.text = "설명"
        descriptionTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.cornerRadius = 5
        
        // 알림 추가 버튼
        let addButton = UIButton(type: .system)
        addButton.setTitle("알림 추가", for: .normal)
        addButton.addTarget(self, action: #selector(addCell), for: .touchUpInside)
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(descriptionTextView.snp.bottom).offset(30)
        }
        
        // 테이블 뷰
        view.addSubview(tableView)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: DatePickerCell.identifier)
        tableView.isEditing = true
        tableView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        //tableView.rx.setDelegate(self)
    }
}

//extension RxSuppComposeViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        guard editingStyle == .delete else { return }
//
//        var alertTimesValue = viewModel.alertTimes.value
//        alertTimesValue.remove(at: indexPath.row)
//        viewModel.alertTimes.accept(alertTimesValue)
//
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 64
//    }
//}
