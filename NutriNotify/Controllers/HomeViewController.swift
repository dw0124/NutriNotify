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
        let button = UIBarButtonItem(title: "RightBtn", style: .plain, target: self, action:#selector(buttonPressed(_:)))
        return button
    }()
    
    @objc func buttonPressed(_ sender: Any) {
        let tableViewController = SuppComposeViewController()
        let navigationController = UINavigationController(rootViewController: tableViewController)
        
        self.present(navigationController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        suppList = DataManager.shared.fetchSupplement()
        
        self.navigationItem.title = "홈"
        self.navigationItem.rightBarButtonItem = rightButton
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
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
//            print("#0 configure")
            cell.configure(supplement)
        } else {
//            print("#1 configure")
        }
        
        return cell
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("-----------------\(suppList?[indexPath.row].name ?? "없음")--------------------------")
        
        if let suppAlertList = suppList?[indexPath.row].suppAlert?.array as? [SuppAlertEntity] {
            for alert in suppAlertList {
                print("SuppAlert 시간: \(alert.alertTime), 복용 여부: \(alert.isTaken)")
                alert.isTaken.toggle()
                DataManager.shared.saveMainContext()
            }
        }
    }

}

