//
//  MyHeaderFooterView.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/06/30.
//

import UIKit

final class MyHeaderFooterView: UICollectionReusableView {
  lazy var label: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(label)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .gray
    NSLayoutConstraint.activate([
      self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.prepare(text: nil)
  }
  
  func prepare(text: String?) {
    self.label.text = text
  }
}
