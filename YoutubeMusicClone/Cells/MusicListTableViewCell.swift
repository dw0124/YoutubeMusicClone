//
//  MusicListTableViewCell.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/27.
//

import UIKit
import Foundation
import SnapKit

class MusicListTableViewCell: UITableViewCell {
    
    static let identifier = "MusicListTableViewCell"
    
    lazy var musicImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .lightGray
        
//        imageView.snp.makeConstraints { (make) in
//            make.width.equalTo(40)
//        }
        
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var singerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //self.image.image = nil // 빈 이미지로 초기화하거나 기본 이미지로 설정하는 등의 작업을 수행합니다.
    }
    
    private func setupCell() {
//        var stackView = UIStackView()
//        stackView.addArrangedSubview(titleLabel)
//        stackView.addArrangedSubview(singerLabel)
//        stackView.axis = .horizontal
//        stackView.spacing = 4
        
//        contentView.addSubview(stackView)
        contentView.addSubview(musicImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(singerLabel)
        
        musicImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().offset(-6)
            $0.width.equalTo(musicImageView.snp.height).multipliedBy(1.0)
        }
        
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(musicImageView)
            make.leading.equalTo(musicImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            //make.centerY.equalToSuperview()
        }

        singerLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(-8) // 추가적인 제약 조건 설정
        }
    }
    
}
