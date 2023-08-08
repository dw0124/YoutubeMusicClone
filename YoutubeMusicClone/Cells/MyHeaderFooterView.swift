//
//  MyHeaderFooterView.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/06/30.
//

import UIKit
import SnapKit

final class MyHeaderFooterView: UICollectionReusableView {
    lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        return label
    }()
    
    lazy var subLabel: UILabel = {
        let label = UILabel()
        label.text = "sub"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainLabel)
        addSubview(subLabel)
        
        mainLabel.snp.makeConstraints { label in
            label.leading.equalToSuperview()
            label.bottom.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints { label in
            label.leading.equalToSuperview()
            label.bottom.equalTo(mainLabel.snp.top).offset(4)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare(text: nil)
    }
    
    func prepare(text: String?) {
        self.mainLabel.text = text
    }
}
