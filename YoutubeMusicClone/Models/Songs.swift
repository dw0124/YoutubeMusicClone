//
//  Songs.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/06/16.
//

import Foundation
import UIKit

struct Songs {
    let image: UIImage
    let title: String
    let singer: String
}

extension Songs {
    static let list: [[Songs]] = [[Songs(image: UIImage(systemName: "music.note")!, title: "acdc", singer: "singer1"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title2", singer: "singer2"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title3", singer: "singer3"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title4", singer: "singer4"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title5", singer: "singer5"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title6", singer: "singer6"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title7", singer: "singer7"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title8", singer: "singer8"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title9", singer: "singer9"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title10", singer: "singe10"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title11", singer: "singer11"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title12", singer: "singer12")],
                                [Songs(image: UIImage(systemName: "music.note")!, title: "title1", singer: "singer1"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title2", singer: "singer2"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title3", singer: "singer3"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title4", singer: "singer4"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title5", singer: "singer5"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title6", singer: "singer6"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title7", singer: "singer7"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title8", singer: "singer8"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title9", singer: "singer9"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title10", singer: "singe10"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title11", singer: "singer11"),
                                Songs(image: UIImage(systemName: "music.note")!, title: "title12", singer: "singer12")],
                                [Songs(image: UIImage(systemName: "music.note")!, title: "title12", singer: "singer12")]]
}
