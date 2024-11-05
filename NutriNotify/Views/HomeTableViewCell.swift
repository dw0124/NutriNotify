//
//  HomeTableViewCell.swift
//  NutriNotify
//
//  Created by 김두원 on 2024/03/15.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

class HomeTableViewCell: UITableViewCell {
    
    static let identifier = "HomeTableViewCell"
    
    var disposeBag = DisposeBag()
    
    var suppAlerts = PublishRelay<[SuppAlert]>()
    
    var stackView = UIStackView()
    
    let labelInset: CGFloat = 24
    
    var collectionViewHeight: CGFloat = 100
    
    var deleteDiaryItemHandelr: (() -> Void)?
    var editDiaryItemHandelr: (() -> Void)?
    
    var titleLabel = UILabel()
    
    lazy var optionsButton: UIButton = {
        let rightButton = UIButton()
        rightButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        let edit = UIAction(
            title: "수정",
            image: UIImage(systemName: "square.and.pencil"),
            handler: { [weak self] _ in
                guard let editDiaryItemHandelr = self?.editDiaryItemHandelr else { return }
                editDiaryItemHandelr()
            }
        )
        let delete = UIAction(
            title: "삭제", image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] _ in
                guard let deleteDiaryItemHandelr = self?.deleteDiaryItemHandelr else { return }
                deleteDiaryItemHandelr()
            }
        )
        let buttonMenu = UIMenu(children: [edit, delete])
        rightButton.menu = buttonMenu
        rightButton.tintColor = .black
        rightButton.showsMenuAsPrimaryAction = true
        return rightButton
    }()
    
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
        binding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .white
        contentView.backgroundColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupCell() {
        selectionStyle = .none
        
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
        let leftEmptyView = UIView()
        leftEmptyView.backgroundColor = .clear
        
        // rightButton의 trailing을 조절하기 위한 빈 뷰
        let rightEmptyView = UIView()
        rightEmptyView.backgroundColor = .clear
        
        let innerStackView = UIStackView()
        innerStackView.axis = .horizontal
        innerStackView.spacing = 8
        
        innerStackView.addArrangedSubview(leftEmptyView)
        innerStackView.addArrangedSubview(titleLabel)
        innerStackView.addArrangedSubview(optionsButton)
        innerStackView.addArrangedSubview(rightEmptyView)
        
        stackView.addArrangedSubview(innerStackView)
        
        // titleLabel의 leading을 조절 / 뷰의 길이 == titleLabel의 leading
        leftEmptyView.snp.makeConstraints {
            $0.width.equalTo(12) // 필요에 따라 조정
        }
        
        
        // rightButton의 trailing을 조절 / 뷰의 길이 == rightButton의 trailing
        rightEmptyView.snp.makeConstraints {
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

    private func binding() {
        suppAlerts
            .bind(to: collectionView.rx.items(cellIdentifier: AlertCheckBoxCell.identifier, cellType: AlertCheckBoxCell.self)) { (row, element, cell) in
                cell.configure(with: element)
            }
            .disposed(by: disposeBag)
    }
    
    // configure
    func configure(_ supplement: Supplement) {
        let alertList = supplement.suppAlerts
        
        self.suppAlerts.accept(alertList)
        
        let lineSpacing: CGFloat = CGFloat(alertList.count - 1) / 3 * 10
        self.collectionViewHeight = CGFloat((alertList.count + 2) / 3) * 100 + lineSpacing
        
        titleLabel.text = supplement.name
        
        collectionView.snp.updateConstraints {
            $0.height.equalTo(collectionViewHeight).priority(.high)
        }
        
        collectionView.isHidden = false
    }
    
    func configure2(_ supplement: Supplement, all: Bool) {
        titleLabel.text = supplement.name
        
        self.collectionViewHeight = 0
        
        collectionView.snp.updateConstraints {
            $0.height.equalTo(collectionViewHeight).priority(.high)
        }
        
        collectionView.isHidden = true
    }
}
