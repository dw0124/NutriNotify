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
import RxDataSources

class RxHomeViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: RxHomeViewModel!
    
    var disposeBag = DisposeBag()
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        setNavigationItem()
    }
    
}
 
extension RxHomeViewController {
    // ViewModel 바인딩
    func bindViewModel() {
        
        _ = tableView.rx.setDelegate(self)
        
        let newDataSource = RxTableViewSectionedReloadDataSource<SectionOfSuppData>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as! HomeTableViewCell

                // 업데이트 메뉴
                cell.editDiaryItemHandelr = {
                    self?.presentComposeVCwithSupplement(item.supplementEntity)
                }

                // 삭제 메뉴
                cell.deleteDiaryItemHandelr = {
                    self?.viewModel.deleteItem(at: indexPath)
                }

                if self?.viewModel.selectedWeekday.value == -1 {
                    cell.configure2(item, all: true)
                } else {
                    cell.configure(item)
                }
                return cell
            }
        )

        viewModel.sectionss
            .bind(to: tableView.rx.items(dataSource: newDataSource))
            .disposed(by: disposeBag)

        // tableView 셀 선택
        tableView.rx.modelSelected(Supplement.self)
            .subscribe(onNext: { [weak self] supplement in
                self?.presentComposeVCwithSupplement(supplement.supplementEntity)
            })
            .disposed(by: disposeBag)

        // tableView 셀 삭제
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.deleteItem(at: indexPath)
            })
            .disposed(by: disposeBag)
    }
    
    // UI 설정 및 레이아웃
    func setupUI() {
        view.backgroundColor = .white
        
        tableView.register(WeekdayHeaderView.self, forHeaderFooterViewReuseIdentifier: WeekdayHeaderView.identifier)
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    // 네비게이션 아이템 설정
    func setNavigationItem() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "EEEE"
        let today = dateFormatter.string(from: date)
        
        self.navigationItem.title = "\(today)"
        
        let presentComposeVCButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action:#selector(presentComposeVC(_:)))
        self.navigationItem.rightBarButtonItem = presentComposeVCButton
    }
    
    // SuppComposeVC로 이동하는 메소드 - 네비게이션 우측 상단 버튼 메소드
    @objc func presentComposeVC(_ sender: Any) {
        var suppComposeVC = RxSuppComposeViewController()
        let suppComposeVM = RxSuppComposeViewModel()
        
        suppComposeVC.bind(viewModel: suppComposeVM)
        suppComposeVC.delegate = self
        
        let navigationController = UINavigationController(rootViewController: suppComposeVC)
        
        self.present(navigationController, animated: true)
    }
    
    // SuppComposeVC로 이동하는 메소드 - 셀에서 supplement를 받아서 업데이트하는 경우
    func presentComposeVCwithSupplement(_ supplement: SupplementEntity) {
        var suppComposeVC = RxSuppComposeViewController()
        let suppComposeVM = RxSuppComposeViewModel(supplement)
        
        suppComposeVC.bind(viewModel: suppComposeVM)
        suppComposeVC.delegate = self
        
        let navigationController = UINavigationController(rootViewController: suppComposeVC)
        
        self.present(navigationController, animated: true)
    }
    
}

extension RxHomeViewController: ComposeVCDelegate {
    func didSaveSupplement(_ supplement: SupplementEntity, isUpdate: Bool) {
        viewModel.addSupplement(supplement, isUpdate: isUpdate)
    }
}
extension RxHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let customHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: WeekdayHeaderView.identifier) as? WeekdayHeaderView else {
            return nil
        }
        
        customHeaderView.selectedWeekdaySubject
            .subscribe(onNext: { [weak self] index in
                self?.viewModel.selectedWeekday.accept(index - 1)
                
                self?.navigationItem.title = customHeaderView.daysOfWeek[index] + "요일"
            })
            .disposed(by: disposeBag)
        
        return customHeaderView
    }
}
