//
//  SongsCollectionViewCell.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/06/16.
//

import Foundation
import UIKit

class MyMusicStationCell: UICollectionViewCell {
    
    static let identifier: String = "MyMusicStationCell"
    
    // UI 요소
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .green
        return imageView
    }()
    
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
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(2.0/5.0)
        }
        
    }
    
    
    // 데이터 설정 메소드
    func configure(with song: Songs) {
        imageView.image = song.image
    }
}
