//
//  HomeTableViewCell.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/15.
//

//
//  FeedTableViewCell.swift
//  MyDiary
//
//  Created by 김두원 on 2023/11/09.
//

import UIKit
import SnapKit

class HomeTableViewCell: UITableViewCell {
    
    static let identifier = "diaryListImageTableViewCell"
    
    var collectionViewHeight: CGFloat = 100
    
    var supplement: SupplementEntity!
    var suppAlertList: [SuppAlertEntity] = []
    
    var stackView = UIStackView()
    
    let labelInset: CGFloat = 24
    
    var titleLabel = UILabel()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        let itemWidth = UIScreen.main.bounds.width / 3 - 10
        let itemHeight: CGFloat = 100
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.backgroundView?.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(AlertCheckBoxCell.self, forCellWithReuseIdentifier: AlertCheckBoxCell.identifier)
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = #colorLiteral(red: 0.9239165187, green: 0.9213962555, blue: 0.9468390346, alpha: 1)
        contentView.backgroundColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupCell() {
        selectionStyle = .none
        
        // CollectionView 설정
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
        // stackView 설정
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.layoutMargins = .init(top: 8, left: 0, bottom: 8, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        // titleLabel 설정
        titleLabel = {
            let label = UILabel()
            label.tintColor = .black
            label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            
            return label
        }()
        
        // titleLabel의 leading을 조절하기 위한 빈 뷰
        let emptyView = UIView()
        emptyView.backgroundColor = .clear
        
        let innerStackView = UIStackView()
        innerStackView.axis = .horizontal
        innerStackView.spacing = 8
        
        innerStackView.addArrangedSubview(emptyView)
        innerStackView.addArrangedSubview(titleLabel)
        
        stackView.addArrangedSubview(innerStackView)
        
        // titleLabel의 leading을 조절 / 뷰의 길이 == titleLabel의 leading
        emptyView.snp.makeConstraints {
            $0.width.equalTo(12) // 필요에 따라 조정
        }
        
        // collectionView 제약 설정
        stackView.addArrangedSubview(collectionView)
        
        // ContentView에 stackView 추가 및 제약 설정
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(collectionViewHeight).priority(.high)
            $0.centerX.equalToSuperview()
        }
    }

    
    
    // configure
    func configure(_ supplement: SupplementEntity) {
        self.supplement = supplement
        
        if let alertList = supplement.suppAlert?.array as? [SuppAlertEntity] {
            self.suppAlertList = alertList
            let lineSpacing: CGFloat = CGFloat(suppAlertList.count - 1) / 3 * 10
            self.collectionViewHeight = CGFloat((suppAlertList.count + 2) / 3) * 100 + lineSpacing
            print("\(self.supplement!.name!)")
            //print("\( self.supplement.objectID.uriRepresentation().absoluteString)")
        }
        
        titleLabel.text = supplement.name
        
        collectionView.snp.updateConstraints {
            $0.height.equalTo(collectionViewHeight).priority(.high)
        }
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension HomeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suppAlertList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlertCheckBoxCell.identifier, for: indexPath) as? AlertCheckBoxCell else { return UICollectionViewCell() }
        
        cell.configure(with: suppAlertList[indexPath.item])
        
//        if let suppAlerts = supplement?.suppAlert?.array as? [SuppAlertEntity] {
//            cell.configure(with: suppAlerts[indexPath.item])
//        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDataSourcePrefetching
extension HomeTableViewCell: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(indexPaths)
    }
}

// MARK: - UICollectionViewDelegate
extension HomeTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print()
    }
}
