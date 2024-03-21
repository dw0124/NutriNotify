//
//  RxTestViewController.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/21.
//
import Foundation
import UIKit
import SnapKit

import RxSwift
import RxCocoa

class RxTestViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: RxTestViewModel!
    
    var disposeBag = DisposeBag()
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setNavigationItem()
    }
    
}
 
extension RxTestViewController {
    // ViewModel 바인딩
    func bindViewModel() {

        viewModel.supplementList.bind(to:
                tableView.rx.items(cellIdentifier: HomeTableViewCell.identifier, cellType: HomeTableViewCell.self)) { row, element, cell in
            cell.configure(element)
        }
        .disposed(by: disposeBag)
    }
    
    // UI 설정 및 레이아웃
    func setupUI() {
        view.backgroundColor = .white
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    // 네비게이션 아이템 설정
    func setNavigationItem() {
        self.navigationItem.title = "홈"
        
        let presentComposeVCButton = UIBarButtonItem(title: "+", style: .plain, target: self, action:#selector(presentComposeVC(_:)))
        self.navigationItem.rightBarButtonItem = presentComposeVCButton
    }
    
    // SuppComposeVC로 이동하는 메소드 - 네비게이션 우측 상단 버튼 메소드
    @objc func presentComposeVC(_ sender: Any) {
        let viewModel = SuppComposeViewModel()
        let composeVC = SuppComposeViewController()
        
        composeVC.viewModel = viewModel
        
        let navigationController = UINavigationController(rootViewController: composeVC)
        
        self.present(navigationController, animated: true)
    }
    
}
