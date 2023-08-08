//
//  Observable.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/11.
//

import Foundation

class Observable<T> {
    
    var value: T? {
        didSet {
            self.listener?(value)
        }
    }
    
    init(_ value: T?) {
        self.value = value
    }
       
    private var listener: ((T?) -> Void)?
    
    func bind(_ listener: @escaping (T?) -> Void) {
        listener(value)
        self.listener = listener
    }
}
