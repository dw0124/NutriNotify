//
//  HomeViewController.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/08.
//

import Foundation
import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    var suppList: [SupplementEntity]?
    
    var tableView = UITableView()
        
    lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "+", style: .plain, target: self, action:#selector(buttonPressed(_:)))
        return button
    }()
    
    @objc func buttonPressed(_ sender: Any) {
        let viewModel = SuppComposeViewModel()
        let composeVC = SuppComposeViewController()
        
        composeVC.viewModel = viewModel
        
        let navigationController = UINavigationController(rootViewController: composeVC)
        
        self.present(navigationController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        suppList = DataManager.shared.fetchSupplement()
        
        self.navigationItem.title = "홈"
        self.navigationItem.rightBarButtonItem = rightButton
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print(self.suppList?.count)
            self.tableView.reloadData()
        }
        
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suppList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        if let supplement = suppList?[indexPath.row] {
            cell.configure(supplement)
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suppComposeVC = SuppComposeViewController()
        let viewModel = SuppComposeViewModel()
        
        viewModel.supplement = suppList?[indexPath.row]
        suppComposeVC.viewModel = viewModel
        
        let navigationController = UINavigationController(rootViewController: suppComposeVC)
        
        self.present(navigationController, animated: true)
    }
}

