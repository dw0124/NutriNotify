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
    
    var supplement: SupplementEntity? = nil
    
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
    
    // setup UI + Layout
    private func setupCell() {
        selectionStyle = .none
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
        titleLabel = {
            let label = UILabel()
            label.tintColor = .black
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            
            return label
        }()
        
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(collectionView)
        
        contentView.addSubview(stackView)
        
        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.width.equalToSuperview()
            //$0.height.equalTo(100)
            $0.centerX.equalToSuperview()
        }
    }
    
    
    // configure
    func configure(_ supplement: SupplementEntity) {
        self.supplement = supplement
        
        titleLabel.text = supplement.name
        
        if let suppAlerts = supplement.suppAlert?.array as? [SuppAlertEntity] {
            self.collectionViewHeight = CGFloat((suppAlerts.count + 2) / 3) * 100
            print("\(self.supplement?.name) count: \(suppAlerts.count)", self.collectionViewHeight)
        }
        
        collectionView.snp.makeConstraints {
            $0.height.equalTo(collectionViewHeight).priority(.high)
        }
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension HomeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return supplement?.suppAlert?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlertCheckBoxCell.identifier, for: indexPath) as? AlertCheckBoxCell else { return UICollectionViewCell() }
        
        cell.backgroundColor = .green
        
        if let suppAlerts = supplement?.suppAlert?.array as? [SuppAlertEntity] {
            cell.configure(with: suppAlerts)
        }
        
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
    
}
