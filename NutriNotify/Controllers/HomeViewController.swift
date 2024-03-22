//
//  HomeViewController.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/08.
//

import Foundation
import UIKit
import SnapKit

class HomeViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: HomeViewModel!

    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationItem()
        setupUI()
    }
    
}

extension HomeViewController {
    
    // ViewModel 바인딩
    func bindViewModel() {
        self.tableView.reloadData()
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
    
    // UI 설정 및 레이아웃
    func setupUI() {
        view.backgroundColor = .white
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.suppList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        if let supplement = viewModel.suppList?[indexPath.row] {
            cell.configure(supplement)
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let supplement = self.viewModel.suppList?[indexPath.row]
        
        var suppComposeVC = SuppComposeViewController()
        let suppComposeVM = SuppComposeViewModel(supplement)
        
        suppComposeVC.bind(viewModel: suppComposeVM)
        
        let navigationController = UINavigationController(rootViewController: suppComposeVC)
        
        self.present(navigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard let supplement = viewModel.suppList?[indexPath.row] else { return }
            DataManager.shared.deleteSupplement(entity: supplement) // CoreData에서 supplement 삭제
            
            viewModel.suppList?.remove(at: indexPath.row) // tableView에 표시되는 배열에서 삭제
            
            tableView.deleteRows(at: [indexPath], with: .fade)  // tableView에서 삭제
            
        } else if editingStyle == .insert {
            
        }
    }
    
}

