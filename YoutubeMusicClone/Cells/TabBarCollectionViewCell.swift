//
//  TabBarCollectionViewCell.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/19.
//


import Foundation
import UIKit

class TabBarCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TabBarCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    // 초기화 메소드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // UI 요소 및 제약조건 설정
    private func setupViews() {
        // UI 요소 추가
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            //make.edges.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

}
